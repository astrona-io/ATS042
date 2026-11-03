#!/usr/bin/env bash
# Check: the password moved to a Secret and the container reads it from there
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

wait_ready() {
  local ns="$1" d="$2" i total ready updated
  for i in $(seq 1 40); do
    total="$(kubectl -n "$ns" get deployment "$d" -o jsonpath='{.status.replicas}' 2>/dev/null || true)"
    ready="$(kubectl -n "$ns" get deployment "$d" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
    updated="$(kubectl -n "$ns" get deployment "$d" -o jsonpath='{.status.updatedReplicas}' 2>/dev/null || true)"
    if [ "$total" = "1" ] && [ "$ready" = "1" ] && [ "$updated" = "1" ]; then return 0; fi
    sleep 3
  done
  return 1
}
# no_host_paths <namespace> <deployment>: fails when the template mounts any host path
no_host_paths() {
  local v
  v="$(kubectl -n "$1" get deployment "$2" -o jsonpath='{.spec.template.spec.volumes[*].hostPath.path}' 2>/dev/null || true)"
  [ -z "$v" ] || bad "$2 still mounts the host path $v"
  wait_ready "$1" "$2" || bad "$2 has no ready replica"
}
# group_denied <namespace> <group> <user>: no group member can read Secrets
group_denied() {
  local ns="$1" group="$2" user="$3" verb ans
  for verb in get list watch; do
    ans="$(kubectl auth can-i "$verb" secrets -n "$ns" --as="$user" --as-group="$group" 2>/dev/null || true)"
    [ "$ans" = "no" ] || bad "members of $group can $verb secrets in $ns"
  done
}
# decoded <namespace> <secret> <key>: prints the decoded Secret value
decoded() {
  local raw
  raw="$(kubectl -n "$1" get secret "$2" -o jsonpath="{.data.$3}" 2>/dev/null || true)"
  printf '%s' "$raw" | base64 -d 2>/dev/null || printf '%s' "$raw" | base64 -D 2>/dev/null || true
}
[ "$(decoded archive snapshot-credentials password)" = "s3cr3t-backup-pass" ] || bad "the Secret snapshot-credentials does not hold the password"
cm="$(kubectl -n archive get configmap snapshot-settings -o jsonpath='{.data.password}' 2>/dev/null || true)"
[ -z "$cm" ] || bad "the ConfigMap still holds a password"
sched="$(kubectl -n archive get configmap snapshot-settings -o jsonpath='{.data.schedule}' 2>/dev/null || true)"
[ -n "$sched" ] || bad "the key schedule was removed from the ConfigMap"
ref="$(kubectl -n archive get deployment snapshotter -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="BACKUP_PASSWORD")].valueFrom.secretKeyRef.name}' 2>/dev/null || true)"
[ "$ref" = "snapshot-credentials" ] || bad "BACKUP_PASSWORD does not read from snapshot-credentials"
wait_ready archive snapshotter || bad "snapshotter has no ready replica"

if [ "$fail" -eq 0 ]; then
  echo "PASS: the password is stored in a Secret"
fi
exit "$fail"
