#!/usr/bin/env bash
# Check: depot rejects hostPath pods and its Deployments stay ready
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
# mounts_claim <namespace> <deployment> <claim>: prints yes when the template references the claim
mounts_claim() {
  local c
  c="$(kubectl -n "$1" get deployment "$2" -o jsonpath='{.spec.template.spec.volumes[*].persistentVolumeClaim.claimName}' 2>/dev/null || true)"
  case " $c " in *" $3 "*) echo yes ;; *) echo no ;; esac
}
# mount_state <namespace> <deployment>: prints name=readOnly; for every mount
mount_state() {
  kubectl -n "$1" get deployment "$2" -o jsonpath='{range .spec.template.spec.containers[*].volumeMounts[*]}{.name}={.readOnly};{end}' 2>/dev/null || true
}
# expect_read_only <namespace> <deployment>: every volume mount is readOnly and the Deployment is ready
expect_read_only() {
  local f
  f="$(kubectl -n "$1" get deployment "$2" -o jsonpath='{range .spec.template.spec.containers[*].volumeMounts[*]}{.name}={.readOnly};{end}' 2>/dev/null || true)"
  [ -n "$f" ] || bad "$2 has no volume mount, it must keep a read-only mount"
  case "$f" in *"=;"*|*"=false;"*) bad "$2 has a mount that is not read-only ($f)" ;; esac
  wait_ready "$1" "$2" || bad "$2 has no ready replica"
}
# pv_policy <namespace> <claim>: prints the reclaim policy of the volume behind the claim
pv_policy() {
  local pv
  pv="$(kubectl -n "$1" get pvc "$2" -o jsonpath='{.spec.volumeName}' 2>/dev/null || true)"
  [ -n "$pv" ] || { echo none; return; }
  kubectl get pv "$pv" -o jsonpath='{.spec.persistentVolumeReclaimPolicy}' 2>/dev/null || true
}
# expect_psa_rejects_hostpath <namespace>: a hostPath pod must be rejected by Pod Security Admission
expect_psa_rejects_hostpath() {
  local ns="$1" i out
  for i in $(seq 1 10); do
    out="$(kubectl -n "$ns" apply --dry-run=server -f - 2>&1 <<'YAML' || true
apiVersion: v1
kind: Pod
metadata:
  name: hostpath-probe
spec:
  containers:
    - name: probe
      image: busybox:1.37.0
      command: ["sleep", "3600"]
      volumeMounts:
        - name: node
          mountPath: /host
  volumes:
    - name: node
      hostPath:
        path: /var/log
YAML
)"
    if printf '%s' "$out" | grep -q 'PodSecurity'; then return 0; fi
    sleep 3
  done
  bad "a hostPath pod is still admitted in $ns"
}
expect_psa_rejects_hostpath depot
for d in writer auditor scanner; do wait_ready depot "$d" || bad "$d has no ready replica"; done

if [ "$fail" -eq 0 ]; then
  echo "PASS: depot rejects hostPath pods and its Deployments are ready"
fi
exit "$fail"
