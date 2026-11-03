#!/usr/bin/env bash
# Check: backup-ops gets archive-key in vault and nothing else
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

expect_allowed "get secret/archive-key in vault" vault backup-ops get secret/archive-key -n vault
for verb in list watch create update patch delete; do
  expect_denied "$verb secrets in vault" vault backup-ops "$verb" secrets -n vault
done
expect_denied "list secrets in all namespaces" vault backup-ops list secrets -A
expect_denied "get secrets in kube-system" vault backup-ops get secrets -n kube-system
expect_denied "get secret/archive-key in kube-system" vault backup-ops get secret/archive-key -n kube-system
expect_denied "get secret/backup-target-credentials in vault" vault backup-ops get secret/backup-target-credentials -n vault

if [ "$fail" -eq 0 ]; then
  echo "PASS: backup-ops reads only archive-key"
fi
exit "$fail"
