#!/usr/bin/env bash
# Check: ci-deployer has no rights beyond Deployments in starfleet
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

expect_denied "delete deployments in starfleet" starfleet ci-deployer delete deployments.apps -n starfleet
expect_denied "read secrets in starfleet" starfleet ci-deployer get secrets -n starfleet
expect_denied "create pods in starfleet" starfleet ci-deployer create pods -n starfleet
expect_denied "list deployments in outpost" starfleet ci-deployer list deployments.apps -n outpost
expect_denied "list nodes" starfleet ci-deployer list nodes
expect_denied "do anything in starfleet" starfleet ci-deployer '*' '*' -n starfleet
kubectl get serviceaccount ci-deployer -n starfleet >/dev/null 2>&1 || bad "the service account ci-deployer was deleted"

if [ "$fail" -eq 0 ]; then
  echo "PASS: ci-deployer has only the Deployment rights"
fi
exit "$fail"
