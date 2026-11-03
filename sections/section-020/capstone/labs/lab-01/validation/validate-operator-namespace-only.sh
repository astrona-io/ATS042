#!/usr/bin/env bash
# Check: ops-operator has no rights outside harbor and no extra verbs
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

expect_denied "list deployments in dock" harbor ops-operator list deployments.apps -n dock
expect_denied "list deployments in all namespaces" harbor ops-operator list deployments.apps --all-namespaces
expect_denied "delete deployments in harbor" harbor ops-operator delete deployments.apps -n harbor
expect_denied "create deployments in harbor" harbor ops-operator create deployments.apps -n harbor
expect_denied "update configmaps in harbor" harbor ops-operator update configmaps -n harbor
expect_denied "do anything in harbor" harbor ops-operator '*' '*' -n harbor

if [ "$fail" -eq 0 ]; then
  echo "PASS: ops-operator is limited to harbor and to the needed verbs"
fi
exit "$fail"
