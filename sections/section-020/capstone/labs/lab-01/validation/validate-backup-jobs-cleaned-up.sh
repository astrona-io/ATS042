#!/usr/bin/env bash
# Check: The CronJob nightly-backup cleans up finished Jobs
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

limit="$(kubectl get cronjob nightly-backup -n harbor -o jsonpath='{.spec.successfulJobsHistoryLimit}' 2>/dev/null || true)"
ttl="$(kubectl get cronjob nightly-backup -n harbor -o jsonpath='{.spec.jobTemplate.spec.ttlSecondsAfterFinished}' 2>/dev/null || true)"
case "$limit" in ''|*[!0-9]*) bad "successfulJobsHistoryLimit is '$limit'" ;; *) [ "$limit" -le 2 ] || bad "successfulJobsHistoryLimit is $limit, expected 2 or less" ;; esac
case "$ttl" in ''|*[!0-9]*) bad "ttlSecondsAfterFinished is not set" ;; *) [ "$ttl" -le 300 ] || bad "ttlSecondsAfterFinished is $ttl, expected 300 or less" ;; esac

if [ "$fail" -eq 0 ]; then
  echo "PASS: finished backup Jobs are cleaned up"
fi
exit "$fail"
