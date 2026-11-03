#!/usr/bin/env bash
# Check: chef reads pods and logs and cannot read Secrets, exec, debug or write pods
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

for verb in get list watch; do
  expect_allowed "$verb pods" galley chef "$verb" pods -n galley
done
expect_allowed "get pods/log" galley chef get pods/log -n galley
for verb in get list watch; do
  expect_denied "$verb secrets" galley chef "$verb" secrets -n galley
done
expect_denied "create pods/exec" galley chef create pods/exec -n galley
expect_denied "create pods/attach" galley chef create pods/attach -n galley
expect_denied "create pods/portforward" galley chef create pods/portforward -n galley
expect_denied "patch pods/ephemeralcontainers" galley chef patch pods/ephemeralcontainers -n galley
expect_denied "update pods/ephemeralcontainers" galley chef update pods/ephemeralcontainers -n galley
expect_denied "create pods" galley chef create pods -n galley
expect_denied "delete pods" galley chef delete pods -n galley

if [ "$fail" -eq 0 ]; then
  echo "PASS: chef has read-only pod access"
fi
exit "$fail"
