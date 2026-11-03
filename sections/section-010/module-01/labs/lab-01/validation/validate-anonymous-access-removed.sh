#!/usr/bin/env bash
# Check: Unauthenticated callers cannot read pods or secrets
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

for res in pods secrets deployments.apps; do
  answer="$(kubectl auth can-i list "$res" -n starfleet --as=system:anonymous --as-group=system:unauthenticated 2>/dev/null || true)"
  [ "$answer" = "no" ] || bad "an unauthenticated caller can list $res in starfleet"
done
if kubectl get clusterrole view >/dev/null 2>&1; then :; else bad "the built-in view ClusterRole is missing"; fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: unauthenticated callers have no access to pods or secrets"
fi
exit "$fail"
