#!/usr/bin/env bash
# Check: builder is not privileged and uses no host namespace
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

priv="$(kubectl -n dock get deployment builder -o jsonpath='{.spec.template.spec.containers[*].securityContext.privileged}' 2>/dev/null || true)"
case "$priv" in *true*) bad "builder still runs privileged" ;; esac
for f in hostPID hostNetwork hostIPC; do
  v="$(kubectl -n dock get deployment builder -o jsonpath="{.spec.template.spec.${f}}" 2>/dev/null || true)"
  [ "$v" != "true" ] || bad "builder sets $f"
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: builder is unprivileged and uses no host namespace"
fi
exit "$fail"
