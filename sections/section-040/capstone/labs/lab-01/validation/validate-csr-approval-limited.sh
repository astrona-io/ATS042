#!/usr/bin/env bash
# Check: Only the group pki-admins can approve certificate requests
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

approve() { kubectl auth can-i update certificatesigningrequests.certificates.k8s.io --subresource=approval --as="$1" --as-group="$2" 2>/dev/null || true; }
[ "$(approve alice system:authenticated)" = "no" ] || bad "an ordinary authenticated user can approve certificate requests"
[ "$(approve bob developers)" = "no" ] || bad "members of the group developers can approve certificate requests"
[ "$(approve carol pki-admins)" = "yes" ] || bad "members of the group pki-admins cannot approve certificate requests"
kubectl get clusterrole csr-approver >/dev/null 2>&1 || bad "the ClusterRole csr-approver was deleted"

if [ "$fail" -eq 0 ]; then
  echo "PASS: only pki-admins can approve certificate requests"
fi
exit "$fail"
