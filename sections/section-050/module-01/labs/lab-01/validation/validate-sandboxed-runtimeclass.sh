#!/usr/bin/env bash
# Check: RuntimeClass sandboxed has the handler runsc and the overhead
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

rc=sandboxed
handler="$(kubectl get runtimeclass "$rc" -o jsonpath='{.handler}' 2>/dev/null || true)"
cpu="$(kubectl get runtimeclass "$rc" -o jsonpath='{.overhead.podFixed.cpu}' 2>/dev/null || true)"
mem="$(kubectl get runtimeclass "$rc" -o jsonpath='{.overhead.podFixed.memory}' 2>/dev/null || true)"
[ "$handler" = "runsc" ] || bad "handler is '$handler', expected runsc"
[ "$cpu" = "100m" ] || bad "overhead cpu is '$cpu', expected 100m"
[ "$mem" = "64Mi" ] || bad "overhead memory is '$mem', expected 64Mi"

if [ "$fail" -eq 0 ]; then
  echo "PASS: RuntimeClass sandboxed is defined"
fi
exit "$fail"
