#!/usr/bin/env bash
# Check: The Deployment cargo runs two ready replicas
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

ready=""
for attempt in $(seq 1 40); do
  ready="$(kubectl -n armada get deployment cargo -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
  [ "$ready" = "2" ] && break
  sleep 4
done
[ "$ready" = "2" ] || bad "cargo has '$ready' ready replicas, expected 2"

if [ "$fail" -eq 0 ]; then
  echo "PASS: cargo runs two ready replicas"
fi
exit "$fail"
