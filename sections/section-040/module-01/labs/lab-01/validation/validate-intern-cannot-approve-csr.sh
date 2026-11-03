#!/usr/bin/env bash
# Check: intern cannot approve certificate signing requests
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

expect_denied "update certificatesigningrequests/approval" starfleet intern update certificatesigningrequests.certificates.k8s.io/approval
expect_denied "approve signers" starfleet intern approve signers.certificates.k8s.io
expect_allowed "list certificatesigningrequests" starfleet intern list certificatesigningrequests.certificates.k8s.io

if [ "$fail" -eq 0 ]; then
  echo "PASS: intern cannot approve certificate requests"
fi
exit "$fail"
