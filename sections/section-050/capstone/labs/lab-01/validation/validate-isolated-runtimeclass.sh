#!/usr/bin/env bash
# Check: RuntimeClass isolated has the handler, selector and overhead
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

rc=isolated
handler="$(kubectl get runtimeclass "$rc" -o jsonpath='{.handler}' 2>/dev/null || true)"
sel="$(kubectl get runtimeclass "$rc" -o jsonpath='{.scheduling.nodeSelector.isolation}' 2>/dev/null || true)"
mem="$(kubectl get runtimeclass "$rc" -o jsonpath='{.overhead.podFixed.memory}' 2>/dev/null || true)"
[ "$handler" = "kata" ] || bad "handler is '$handler', expected kata"
[ "$sel" = "strong" ] || bad "nodeSelector isolation is '$sel', expected strong"
[ "$mem" = "128Mi" ] || bad "overhead memory is '$mem', expected 128Mi"
for d in loader builder runner; do
  used="$(kubectl -n dock get deployment "$d" -o jsonpath='{.spec.template.spec.runtimeClassName}' 2>/dev/null || true)"
  [ -z "$used" ] || bad "$d uses the runtime class $used"
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: RuntimeClass isolated is defined and unused"
fi
exit "$fail"
