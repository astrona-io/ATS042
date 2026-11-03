#!/usr/bin/env bash
# Check: fleet-controller reads ConfigMaps in starfleet only
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
  expect_allowed "$verb configmaps in starfleet" starfleet fleet-controller "$verb" configmaps -n starfleet
done
expect_denied "list configmaps in outpost" starfleet fleet-controller list configmaps -n outpost
expect_denied "list configmaps in all namespaces" starfleet fleet-controller list configmaps --all-namespaces
expect_denied "do anything in starfleet" starfleet fleet-controller '*' '*' -n starfleet
kubectl get clusterrolebindings -o json | jq -e '[.items[] | select(any(.subjects[]?; .name=="fleet-controller" and .kind=="ServiceAccount"))] | length == 0' >/dev/null || bad "a ClusterRoleBinding still names fleet-controller"

if [ "$fail" -eq 0 ]; then
  echo "PASS: fleet-controller reads ConfigMaps in starfleet only"
fi
exit "$fail"
