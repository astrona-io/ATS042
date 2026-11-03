#!/usr/bin/env bash
# Check: lane-ops cannot write Endpoints or EndpointSlices
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

for ns in lane default kube-system; do
  for verb in create update patch delete; do
    expect_denied "$verb endpoints in $ns" lane lane-ops "$verb" endpoints -n "$ns"
    expect_denied "$verb endpointslices in $ns" lane lane-ops "$verb" endpointslices.discovery.k8s.io -n "$ns"
  done
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: lane-ops cannot write Endpoints or EndpointSlices"
fi
exit "$fail"
