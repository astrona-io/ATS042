#!/usr/bin/env bash
# Check: fleet-controller changes only the ConfigMap fleet-state
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

expect_allowed "update the ConfigMap fleet-state" starfleet fleet-controller update configmaps/fleet-state -n starfleet
expect_allowed "patch the ConfigMap fleet-state" starfleet fleet-controller patch configmaps/fleet-state -n starfleet
expect_denied "update the ConfigMap fleet-notes" starfleet fleet-controller update configmaps/fleet-notes -n starfleet
expect_denied "delete the ConfigMap fleet-state" starfleet fleet-controller delete configmaps/fleet-state -n starfleet
expect_denied "create configmaps" starfleet fleet-controller create configmaps -n starfleet

if [ "$fail" -eq 0 ]; then
  echo "PASS: fleet-controller updates only fleet-state"
fi
exit "$fail"
