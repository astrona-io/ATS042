#!/usr/bin/env bash
# Check: loader has no legacy token and no cluster-wide rights
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

if kubectl -n deck get secret loader-token >/dev/null 2>&1; then bad "the legacy token Secret loader-token still exists"; fi
if kubectl -n deck get secrets -o jsonpath='{range .items[*]}{.type}{"\n"}{end}' 2>/dev/null | grep -q 'kubernetes.io/service-account-token'; then bad "a legacy token Secret still exists in deck"; fi
expect_denied "do everything" deck loader '*' '*'
expect_denied "list nodes" deck loader list nodes

if [ "$fail" -eq 0 ]; then
  echo "PASS: loader has no legacy token and no cluster-wide rights"
fi
exit "$fail"
