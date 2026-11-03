#!/usr/bin/env bash
# Check: Deployments in orbit need a team label
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

deployment_dry_run() {
  kubectl apply --dry-run=server -f - <<EOF >/dev/null 2>&1
apiVersion: apps/v1
kind: Deployment
metadata:
  name: label-test
  namespace: orbit
  labels:
    ${1}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: label-test
  template:
    metadata:
      labels:
        app: label-test
    spec:
      containers:
        - name: test
          image: busybox:1.37.0
          command: ["sleep", "3600"]
EOF
}
rejected=0
for attempt in $(seq 1 15); do
  if ! deployment_dry_run "app: label-test"; then rejected=1; break; fi
  sleep 2
done
[ "$rejected" -eq 1 ] || bad "a Deployment without a team label was accepted in orbit"
deployment_dry_run "team: blue" || bad "a Deployment with a team label was rejected in orbit"

if [ "$fail" -eq 0 ]; then
  echo "PASS: a Deployment without a team label is rejected and one with it is accepted"
fi
exit "$fail"
