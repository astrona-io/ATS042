#!/usr/bin/env bash
# Check: all three Deployments are ready and set restricted-compatible security contexts
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
# rejects_pod <namespace> <securityContext yaml lines>: true when Pod Security Admission rejects the pod
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
for d in loader builder runner; do
  wait_ready dock "$d" || bad "$d does not have exactly one updated and ready replica"
  base='{.spec.template.spec'
  nr="$(kubectl -n dock get deployment "$d" -o jsonpath="${base}.securityContext.runAsNonRoot}" 2>/dev/null || true)"
  cnr="$(kubectl -n dock get deployment "$d" -o jsonpath="${base}.containers[0].securityContext.runAsNonRoot}" 2>/dev/null || true)"
  if [ "$nr" != "true" ] && [ "$cnr" != "true" ]; then bad "$d does not set runAsNonRoot"; fi
  sc="$(kubectl -n dock get deployment "$d" -o jsonpath="${base}.securityContext.seccompProfile.type}" 2>/dev/null || true)"
  csc="$(kubectl -n dock get deployment "$d" -o jsonpath="${base}.containers[0].securityContext.seccompProfile.type}" 2>/dev/null || true)"
  if [ "$sc" != "RuntimeDefault" ] && [ "$csc" != "RuntimeDefault" ]; then bad "$d does not set the RuntimeDefault seccomp profile"; fi
  esc="$(kubectl -n dock get deployment "$d" -o jsonpath="${base}.containers[0].securityContext.allowPrivilegeEscalation}" 2>/dev/null || true)"
  [ "$esc" = "false" ] || bad "$d does not forbid privilege escalation"
  drop="$(kubectl -n dock get deployment "$d" -o jsonpath="${base}.containers[0].securityContext.capabilities.drop}" 2>/dev/null || true)"
  case "$drop" in *ALL*) ;; *) bad "$d does not drop all capabilities" ;; esac
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: all three Deployments are ready and comply"
fi
exit "$fail"
