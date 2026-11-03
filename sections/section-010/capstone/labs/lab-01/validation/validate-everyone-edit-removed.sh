#!/usr/bin/env bash
# Check: Authenticated users cannot edit objects across namespaces
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

answer="$(kubectl auth can-i create deployments.apps -n starfleet --as=nobody --as-group=system:authenticated 2>/dev/null || true)"
[ "$answer" = "no" ] || bad "any authenticated user can create Deployments in starfleet"
answer="$(kubectl auth can-i create deployments.apps -n orbit --as=nobody --as-group=system:authenticated 2>/dev/null || true)"
[ "$answer" = "no" ] || bad "any authenticated user can create Deployments in orbit"

if [ "$fail" -eq 0 ]; then
  echo "PASS: authenticated users have no edit rights"
fi
exit "$fail"
