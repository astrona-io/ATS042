#!/usr/bin/env bash
# Check: developers read Secrets in orbit only
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

[ "$(kubectl auth can-i get secrets -n orbit --as=dev-anna --as-group=developers 2>/dev/null || true)" = "yes" ] || bad "developers cannot read Secrets in orbit"
[ "$(kubectl auth can-i get secrets -n starfleet --as=dev-anna --as-group=developers 2>/dev/null || true)" = "no" ] || bad "developers can read Secrets in starfleet"
[ "$(kubectl auth can-i list secrets --all-namespaces --as=dev-anna --as-group=developers 2>/dev/null || true)" = "no" ] || bad "developers can list Secrets in all namespaces"

if [ "$fail" -eq 0 ]; then
  echo "PASS: developers read Secrets in orbit only"
fi
exit "$fail"
