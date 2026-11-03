#!/usr/bin/env bash
# Check: hangar enforces the restricted standard and rejects a privileged pod
set -uo pipefail
  fail=0
  bad() { echo "FAIL: $*"; fail=1; }
sa_can() {
  local ns="$1" sa="$2" a; shift 2
  local args=()
  for a in "$@"; do
    case "$a" in
      pods/*|nodes/*|certificatesigningrequests*/*) args+=("${a%%/*}" "--subresource=${a#*/}") ;;
      *) args+=("$a") ;;
    esac
  done
  kubectl auth can-i "${args[@]}" --as="system:serviceaccount:${ns}:${sa}" 2>/dev/null || true
}
  # expect_allowed <description> <ns> <sa> <can-i args>
  expect_allowed() { local d="$1" ns="$2" sa="$3"; shift 3; [ "$(sa_can "$ns" "$sa" "$@")" = "yes" ] || bad "$sa cannot $d"; }
  # expect_denied <description> <ns> <sa> <can-i args>
  expect_denied() { local d="$1" ns="$2" sa="$3"; shift 3; [ "$(sa_can "$ns" "$sa" "$@")" = "no" ] || bad "$sa is allowed to $d"; }

wait_ready() {
  local ns="$1" d="$2" i total ready updated
  for i in $(seq 1 40); do
    total="$(kubectl -n "$ns" get deployment "$d" -o jsonpath='{.status.replicas}' 2>/dev/null || true)"
    ready="$(kubectl -n "$ns" get deployment "$d" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
    updated="$(kubectl -n "$ns" get deployment "$d" -o jsonpath='{.status.updatedReplicas}' 2>/dev/null || true)"
    if [ "$total" = "1" ] && [ "$ready" = "1" ] && [ "$updated" = "1" ]; then return 0; fi
    sleep 3
  done
  return 1
}
# jp <namespace> <deployment> <jsonpath>: prints a field of the Deployment, empty when unset
jp() { kubectl -n "$1" get deployment "$2" -o jsonpath="$3" 2>/dev/null || true; }
# check_hardened <namespace> <deployment>: fails through bad when the template keeps risky settings
check_hardened() {
  local ns="$1" d="$2" v
  v="$(jp "$ns" "$d" '{.spec.template.spec.containers[*].securityContext.privileged} {.spec.template.spec.initContainers[*].securityContext.privileged}')"
  case "$v" in *true*) bad "$d still runs a privileged container" ;; esac
  v="$(jp "$ns" "$d" '{.spec.template.spec.hostNetwork} {.spec.template.spec.hostPID} {.spec.template.spec.hostIPC}')"
  case "$v" in *true*) bad "$d still uses a host namespace" ;; esac
  v="$(jp "$ns" "$d" '{.spec.template.spec.volumes[*].hostPath.path}')"
  [ -z "$v" ] || bad "$d still mounts the host path $v"
  v="$(jp "$ns" "$d" '{.spec.template.spec.containers[*].securityContext.allowPrivilegeEscalation}')"
  [ "$v" = "false" ] || bad "$d does not set allowPrivilegeEscalation to false"
  v="$(jp "$ns" "$d" '{.spec.template.spec.containers[*].securityContext.capabilities.drop[*]}')"
  case "$v" in *ALL*) ;; *) bad "$d does not drop all capabilities" ;; esac
  v="$(jp "$ns" "$d" '{.spec.template.spec.containers[*].securityContext.capabilities.add[*]}')"
  [ -z "$v" ] || bad "$d still adds capabilities: $v"
  v="$(jp "$ns" "$d" '{.spec.template.spec.securityContext.runAsNonRoot} {.spec.template.spec.containers[*].securityContext.runAsNonRoot}')"
  case "$v" in *true*) ;; *) bad "$d does not set runAsNonRoot" ;; esac
  v="$(jp "$ns" "$d" '{.spec.template.spec.securityContext.seccompProfile.type} {.spec.template.spec.containers[*].securityContext.seccompProfile.type}')"
  case "$v" in *RuntimeDefault*) ;; *) bad "$d does not select the RuntimeDefault seccomp profile" ;; esac
  wait_ready "$ns" "$d" || bad "$d has no ready replica"
}
# check_no_token <namespace> <name>: the service account and the running pods carry no API token
check_no_token() {
  local ns="$1" n="$2" v
  v="$(kubectl -n "$ns" get serviceaccount "$n" -o jsonpath='{.automountServiceAccountToken}' 2>/dev/null || true)"
  [ "$v" = "false" ] || bad "service account $n does not set automountServiceAccountToken to false"
  v="$(jp "$ns" "$n" '{.spec.template.spec.automountServiceAccountToken}')"
  [ "$v" = "false" ] || bad "$n does not set automountServiceAccountToken to false in the pod template"
  wait_ready "$ns" "$n" || bad "$n has no ready replica"
  v="$(kubectl -n "$ns" get pods -l "app=$n" -o jsonpath='{.items[*].spec.volumes[*].name}' 2>/dev/null || true)"
  case "$v" in *kube-api-access*) bad "a running $n pod still mounts an API token" ;; esac
}
# rejects_pod <namespace>: true when Pod Security Admission rejects a privileged pod
rejects_pod() {
  local ns="$1" f out i
  f="$(mktemp)"
  printf 'apiVersion: v1\nkind: Pod\nmetadata:\n  name: policy-probe\n  namespace: %s\nspec:\n  containers:\n    - name: probe\n      image: busybox:1.37.0\n      command: ["sleep", "60"]\n      securityContext:\n        privileged: true\n' "$ns" > "$f"
  for i in $(seq 1 10); do
    out="$(kubectl apply --dry-run=server -f "$f" 2>&1 || true)"
    if echo "$out" | grep -q "PodSecurity"; then rm -f "$f"; return 0; fi
    sleep 2
  done
  rm -f "$f"
  return 1
}
level="$(kubectl get namespace hangar -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' 2>/dev/null || true)"
[ "$level" = "restricted" ] || bad "enforce label is '$level', expected restricted"
rejects_pod hangar || bad "a privileged pod is not rejected in hangar"

if [ "$fail" -eq 0 ]; then
  echo "PASS: hangar enforces the restricted standard"
fi
exit "$fail"
