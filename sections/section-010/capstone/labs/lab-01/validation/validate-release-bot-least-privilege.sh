#!/usr/bin/env bash
# Check: release-bot has exactly the rights it needs in orbit
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

for verb in create update patch; do
  expect_allowed "$verb deployments in orbit" orbit release-bot "$verb" deployments.apps -n orbit
done
expect_allowed "list pods in orbit" orbit release-bot list pods -n orbit
expect_denied "delete deployments in orbit" orbit release-bot delete deployments.apps -n orbit
expect_denied "read secrets in orbit" orbit release-bot get secrets -n orbit
expect_denied "create services in orbit" orbit release-bot create services -n orbit
expect_denied "list pods in starfleet" orbit release-bot list pods -n starfleet

if [ "$fail" -eq 0 ]; then
  echo "PASS: release-bot has only the required rights"
fi
exit "$fail"
