#!/usr/bin/env bash
# Check: intern cannot write Services, Endpoints or EndpointSlices but can read Services
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

for verb in create update patch delete; do
  for res in services endpoints endpointslices.discovery.k8s.io; do
    expect_denied "$verb $res" starfleet intern "$verb" "$res" -n starfleet
  done
done
expect_allowed "get services" starfleet intern get services -n starfleet
expect_allowed "list services" starfleet intern list services -n starfleet

if [ "$fail" -eq 0 ]; then
  echo "PASS: intern has read-only access to Services and endpoints"
fi
exit "$fail"
