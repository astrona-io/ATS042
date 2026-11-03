#!/usr/bin/env bash
# Check: inspector has no hostPath volume and is ready
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

host="$(kubectl -n deck get deployment inspector -o jsonpath='{range .spec.template.spec.volumes[*]}{.hostPath.path}{"\n"}{end}' 2>/dev/null | grep -c . || true)"
[ "$host" = "0" ] || bad "the Deployment inspector still has a hostPath volume"
ready=""
for attempt in $(seq 1 30); do
  ready="$(kubectl -n deck get deployment inspector -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
  [ "$ready" = "1" ] && break
  sleep 4
done
[ "$ready" = "1" ] || bad "inspector has '$ready' ready replicas, expected 1"

if [ "$fail" -eq 0 ]; then
  echo "PASS: inspector runs without a hostPath volume"
fi
exit "$fail"
