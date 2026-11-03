#!/usr/bin/env bash
# Check: A pod with spec.nodeName is rejected in outpost
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

pod_with_node_name() {
  kubectl apply --dry-run=server -f - <<EOF >/dev/null 2>&1
apiVersion: v1
kind: Pod
metadata:
  name: pinned-test
  namespace: outpost
spec:
  nodeName: not-a-real-node
  containers:
    - name: test
      image: busybox:1.37.0
      command: ["sleep", "3600"]
EOF
}
pod_without_node_name() {
  kubectl apply --dry-run=server -f - <<EOF >/dev/null 2>&1
apiVersion: v1
kind: Pod
metadata:
  name: free-test
  namespace: outpost
spec:
  containers:
    - name: test
      image: busybox:1.37.0
      command: ["sleep", "3600"]
EOF
}
rejected=0
for attempt in $(seq 1 15); do
  if ! pod_with_node_name; then rejected=1; break; fi
  sleep 4
done
[ "$rejected" -eq 1 ] || bad "a pod with spec.nodeName was accepted in outpost"
pod_without_node_name || bad "a normal pod without nodeName was rejected in outpost"

if [ "$fail" -eq 0 ]; then
  echo "PASS: pods with spec.nodeName are rejected in outpost"
fi
exit "$fail"
