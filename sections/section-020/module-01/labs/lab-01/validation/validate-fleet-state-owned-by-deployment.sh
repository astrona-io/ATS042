#!/usr/bin/env bash
# Check: The ConfigMap fleet-state is owned by the Deployment fleet-controller
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

deployment_uid="$(kubectl get deployment fleet-controller -n starfleet -o jsonpath='{.metadata.uid}' 2>/dev/null || true)"
owner_uid="$(kubectl get configmap fleet-state -n starfleet -o jsonpath='{.metadata.ownerReferences[0].uid}' 2>/dev/null || true)"
owner_kind="$(kubectl get configmap fleet-state -n starfleet -o jsonpath='{.metadata.ownerReferences[0].kind}' 2>/dev/null || true)"
[ -n "$deployment_uid" ] || bad "the Deployment fleet-controller does not exist"
[ "$owner_kind" = "Deployment" ] || bad "the owner kind is '$owner_kind', expected Deployment"
[ "$owner_uid" = "$deployment_uid" ] || bad "the owner uid does not match the Deployment"

if [ "$fail" -eq 0 ]; then
  echo "PASS: fleet-state is owned by the Deployment"
fi
exit "$fail"
