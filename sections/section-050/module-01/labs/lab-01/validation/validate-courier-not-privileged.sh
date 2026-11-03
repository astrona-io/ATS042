#!/usr/bin/env bash
# Check: courier is not privileged and drops all capabilities
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

path='{.spec.template.spec.containers[0].securityContext'
priv="$(kubectl -n outpost get deployment courier -o jsonpath="${path}.privileged}" 2>/dev/null || true)"
esc="$(kubectl -n outpost get deployment courier -o jsonpath="${path}.allowPrivilegeEscalation}" 2>/dev/null || true)"
drop="$(kubectl -n outpost get deployment courier -o jsonpath="${path}.capabilities.drop}" 2>/dev/null || true)"
add="$(kubectl -n outpost get deployment courier -o jsonpath="${path}.capabilities.add}" 2>/dev/null || true)"
[ "$priv" != "true" ] || bad "the container still runs privileged"
[ "$esc" = "false" ] || bad "allowPrivilegeEscalation is '$esc', expected false"
case "$drop" in *ALL*) ;; *) bad "capabilities.drop does not contain ALL" ;; esac
[ -z "$add" ] || bad "the container still adds capabilities: $add"

if [ "$fail" -eq 0 ]; then
  echo "PASS: courier is unprivileged and drops all capabilities"
fi
exit "$fail"
