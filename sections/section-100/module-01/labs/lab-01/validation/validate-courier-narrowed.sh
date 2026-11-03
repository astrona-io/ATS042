#!/usr/bin/env bash
# Check: courier has no legacy token and only reads pods in dock
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

if kubectl -n dock get secret courier-token >/dev/null 2>&1; then bad "the legacy token Secret courier-token still exists"; fi
if kubectl -n dock get secrets -o jsonpath='{range .items[*]}{.type}{"\n"}{end}' 2>/dev/null | grep -q 'kubernetes.io/service-account-token'; then bad "a legacy token Secret still exists in dock"; fi
expect_allowed "list pods in dock" dock courier list pods -n dock
expect_allowed "get pods in dock" dock courier get pods -n dock
expect_denied "delete pods in dock" dock courier delete pods -n dock
expect_denied "read secrets in dock" dock courier get secrets -n dock
expect_denied "list pods in other namespaces" dock courier list pods -n starfleet
expect_denied "do everything" dock courier '*' '*'

if [ "$fail" -eq 0 ]; then
  echo "PASS: courier is limited to reading pods in dock"
fi
exit "$fail"
