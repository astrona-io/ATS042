#!/usr/bin/env bash
# Check: relay reads ConfigMaps but not Secrets and cannot exec
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

expect_allowed "get configmaps" hangar relay get configmaps -n hangar
expect_allowed "list configmaps" hangar relay list configmaps -n hangar
for verb in get list watch; do
  expect_denied "$verb secrets" hangar relay "$verb" secrets -n hangar
done
expect_denied "create pods/exec" hangar relay create pods/exec -n hangar
expect_denied "patch pods/ephemeralcontainers" hangar relay patch pods/ephemeralcontainers -n hangar
expect_denied "update pods/ephemeralcontainers" hangar relay update pods/ephemeralcontainers -n hangar
expect_denied "create pods" hangar relay create pods -n hangar

if [ "$fail" -eq 0 ]; then
  echo "PASS: relay keeps ConfigMap reads only"
fi
exit "$fail"
