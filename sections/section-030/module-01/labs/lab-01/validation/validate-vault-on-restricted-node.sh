#!/usr/bin/env bash
# Check: The vault pod runs on the restricted node
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

restricted="$(kubectl get nodes -l tier=restricted -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || true)"
[ -n "$restricted" ] || bad "no node has the label tier=restricted"
set -- $restricted
[ "$#" -eq 1 ] || bad "expected one restricted node, found $#"
selector="$(kubectl -n starfleet get deployment vault -o jsonpath='{.spec.template.spec.nodeSelector.tier}' 2>/dev/null || true)"
[ "$selector" = "restricted" ] || bad "the nodeSelector tier=restricted was removed from vault"
taint="$(kubectl get node "$1" -o jsonpath='{.spec.taints[?(@.key=="tier")].effect}' 2>/dev/null || true)"
[ "$taint" = "NoSchedule" ] || bad "the taint tier=restricted:NoSchedule is missing from the restricted node"
pod_node=""
for attempt in $(seq 1 30); do
  pod_node="$(kubectl -n starfleet get pods -l app=vault --field-selector=status.phase=Running -o jsonpath='{.items[0].spec.nodeName}' 2>/dev/null || true)"
  [ -n "$pod_node" ] && break
  sleep 4
done
[ "$pod_node" = "$1" ] || bad "the vault pod runs on '$pod_node', expected $1"

if [ "$fail" -eq 0 ]; then
  echo "PASS: vault runs on the restricted node"
fi
exit "$fail"
