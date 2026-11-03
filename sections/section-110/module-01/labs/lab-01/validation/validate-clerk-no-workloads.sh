#!/usr/bin/env bash
# Check: clerk reads claims and starts nothing
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

expect_allowed "get claims" ledger clerk get persistentvolumeclaims -n ledger
expect_allowed "list claims" ledger clerk list persistentvolumeclaims -n ledger
expect_denied "create pods" ledger clerk create pods -n ledger
expect_denied "create deployments" ledger clerk create deployments -n ledger
expect_denied "create jobs" ledger clerk create jobs -n ledger
expect_denied "exec into pods" ledger clerk create pods/exec -n ledger
expect_denied "delete claims" ledger clerk delete persistentvolumeclaims -n ledger

if [ "$fail" -eq 0 ]; then
  echo "PASS: clerk can read claims and cannot start workloads"
fi
exit "$fail"
