#!/usr/bin/env bash
# Check: lane-ops manages Services only in lane
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
  expect_allowed "$verb services in lane" lane lane-ops "$verb" services -n lane
  expect_denied "$verb services in default" lane lane-ops "$verb" services -n default
  expect_denied "$verb services in kube-system" lane lane-ops "$verb" services -n kube-system
done
expect_allowed "list endpointslices in lane" lane lane-ops list endpointslices.discovery.k8s.io -n lane

if [ "$fail" -eq 0 ]; then
  echo "PASS: lane-ops manages Services only in lane"
fi
exit "$fail"
