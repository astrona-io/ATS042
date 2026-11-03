#!/usr/bin/env bash
# Check: a policy in bay isolates every Pod for ingress
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

lines="$(kubectl -n bay get networkpolicy -o jsonpath='{range .items[*]}{.spec.podSelector}{"|"}{.spec.policyTypes}{"\n"}{end}' 2>/dev/null || true)"
echo "$lines" | grep -Eq '^\{\}\|.*Ingress' || bad "no policy in bay selects every Pod for ingress"

if [ "$fail" -eq 0 ]; then
  echo "PASS: bay has a default deny ingress policy"
fi
exit "$fail"
