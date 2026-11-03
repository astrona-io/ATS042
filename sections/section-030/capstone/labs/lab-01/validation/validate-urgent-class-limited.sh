#!/usr/bin/env bash
# Check: New pods cannot use the urgent priority class in armada
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

urgent_pod() {
  kubectl apply --dry-run=server -f - <<EOF 2>&1
apiVersion: v1
kind: Pod
metadata:
  name: urgent-test
  namespace: armada
spec:
  priorityClassName: urgent
  containers:
    - name: test
      image: busybox:1.37.0
      command: ["sleep", "3600"]
      resources:
        requests:
          cpu: 10m
          memory: 8Mi
        limits:
          cpu: 10m
          memory: 8Mi
EOF
}
plain_pod() {
  kubectl apply --dry-run=server -f - <<EOF >/dev/null 2>&1
apiVersion: v1
kind: Pod
metadata:
  name: plain-test
  namespace: armada
spec:
  containers:
    - name: test
      image: busybox:1.37.0
      command: ["sleep", "3600"]
      resources:
        requests:
          cpu: 10m
          memory: 8Mi
        limits:
          cpu: 10m
          memory: 8Mi
EOF
}
rejected=0
for attempt in $(seq 1 15); do
  out="$(urgent_pod || true)"
  case "$out" in *"exceeded quota"*|*"forbidden"*) rejected=1; break ;; esac
  sleep 4
done
[ "$rejected" -eq 1 ] || bad "a pod with priorityClassName urgent was accepted in armada"
plain_pod || bad "a pod without a priority class was rejected in armada"
kubectl get priorityclass urgent -o jsonpath='{.value}' 2>/dev/null | grep -q '^1000000$' || bad "the PriorityClass urgent was changed or deleted"

if [ "$fail" -eq 0 ]; then
  echo "PASS: pods cannot use the urgent priority class in armada"
fi
exit "$fail"
