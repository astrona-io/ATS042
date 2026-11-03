#!/usr/bin/env bash
# Check: snapshotter gets backup-key in archive and cannot read other Secrets
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

expect_allowed "get secret/backup-key in archive" archive snapshotter get secret/backup-key -n archive
expect_denied "list secrets in archive" archive snapshotter list secrets -n archive
expect_denied "watch secrets in archive" archive snapshotter watch secrets -n archive
expect_denied "list secrets in all namespaces" archive snapshotter list secrets -A
expect_denied "get secrets in kube-system" archive snapshotter get secrets -n kube-system
expect_denied "get secret/backup-key in kube-system" archive snapshotter get secret/backup-key -n kube-system
expect_denied "get secret/snapshot-credentials in archive" archive snapshotter get secret/snapshot-credentials -n archive
expect_denied "update secret/backup-key" archive snapshotter update secret/backup-key -n archive

if [ "$fail" -eq 0 ]; then
  echo "PASS: snapshotter reads only backup-key"
fi
exit "$fail"
