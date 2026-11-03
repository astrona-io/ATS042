#!/usr/bin/env bash
# Check: loader gets and patches Deployments in deck only
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

expect_allowed "get deployments in deck" deck loader get deployments -n deck
expect_allowed "patch deployments in deck" deck loader patch deployments -n deck
expect_denied "create deployments in deck" deck loader create deployments -n deck
expect_denied "delete deployments in deck" deck loader delete deployments -n deck
expect_denied "read secrets in deck" deck loader get secrets -n deck
expect_denied "patch deployments in starfleet" deck loader patch deployments -n starfleet

if [ "$fail" -eq 0 ]; then
  echo "PASS: loader can only get and patch Deployments in deck"
fi
exit "$fail"
