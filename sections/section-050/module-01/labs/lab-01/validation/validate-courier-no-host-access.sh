#!/usr/bin/env bash
# Check: courier has no hostPath volume or host namespace and is ready
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
spec='{.spec.template.spec'
hp="$(kubectl -n outpost get deployment courier -o jsonpath="${spec}.volumes[*].hostPath.path}" 2>/dev/null || true)"
[ -z "$hp" ] || bad "the pod template still has a hostPath volume: $hp"
for f in hostPID hostNetwork hostIPC; do
  v="$(kubectl -n outpost get deployment courier -o jsonpath="${spec}.${f}}" 2>/dev/null || true)"
  [ "$v" != "true" ] || bad "the pod template sets $f"
done
wait_ready outpost courier || bad "courier does not have exactly one updated and ready replica"

if [ "$fail" -eq 0 ]; then
  echo "PASS: courier has no host access and is ready"
fi
exit "$fail"
