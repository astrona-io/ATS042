#!/usr/bin/env bash
# Check: ops-operator cannot read Secrets or escalate
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

expect_denied "read secrets in harbor" harbor ops-operator get secrets -n harbor
expect_denied "read secrets in dock" harbor ops-operator get secrets -n dock
expect_denied "list secrets in all namespaces" harbor ops-operator list secrets --all-namespaces
expect_denied "escalate clusterroles" harbor ops-operator escalate clusterroles.rbac.authorization.k8s.io
expect_denied "bind clusterroles" harbor ops-operator bind clusterroles.rbac.authorization.k8s.io

if [ "$fail" -eq 0 ]; then
  echo "PASS: ops-operator cannot read Secrets or escalate"
fi
exit "$fail"
