#!/usr/bin/env bash
# Check: intern reads claims and starts nothing
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

expect_allowed "get claims" depot intern get persistentvolumeclaims -n depot
expect_allowed "list claims" depot intern list persistentvolumeclaims -n depot
expect_denied "create pods" depot intern create pods -n depot
expect_denied "create jobs" depot intern create jobs -n depot
expect_denied "create deployments" depot intern create deployments -n depot
expect_denied "exec into pods" depot intern create pods/exec -n depot

if [ "$fail" -eq 0 ]; then
  echo "PASS: intern can read claims and cannot start workloads"
fi
exit "$fail"
