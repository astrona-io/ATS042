#!/usr/bin/env bash
# Check: No other workload tolerates the restricted taint
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

for d in scout; do
  tol="$(kubectl -n starfleet get deployment "$d" -o jsonpath='{.spec.template.spec.tolerations}' 2>/dev/null || true)"
  [ -z "$tol" ] || bad "the Deployment $d has tolerations: $tol"
done
restricted="$(kubectl get nodes -l tier=restricted -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
on_restricted="$(kubectl -n starfleet get pods -l app=scout -o jsonpath="{.items[?(@.spec.nodeName==\"$restricted\")].metadata.name}" 2>/dev/null || true)"
[ -z "$on_restricted" ] || bad "scout pods run on the restricted node: $on_restricted"

if [ "$fail" -eq 0 ]; then
  echo "PASS: only vault may run on the restricted node"
fi
exit "$fail"
