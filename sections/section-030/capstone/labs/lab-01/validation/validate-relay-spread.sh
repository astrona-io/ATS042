#!/usr/bin/env bash
# Check: The relay replicas run on different nodes and the spread is required
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

key="$(kubectl -n armada get deployment relay -o jsonpath='{.spec.template.spec.topologySpreadConstraints[0].topologyKey}' 2>/dev/null || true)"
when="$(kubectl -n armada get deployment relay -o jsonpath='{.spec.template.spec.topologySpreadConstraints[0].whenUnsatisfiable}' 2>/dev/null || true)"
skew="$(kubectl -n armada get deployment relay -o jsonpath='{.spec.template.spec.topologySpreadConstraints[0].maxSkew}' 2>/dev/null || true)"
[ "$key" = "kubernetes.io/hostname" ] || bad "topologyKey is '$key', expected kubernetes.io/hostname"
[ "$when" = "DoNotSchedule" ] || bad "whenUnsatisfiable is '$when', expected DoNotSchedule"
[ "$skew" = "1" ] || bad "maxSkew is '$skew', expected 1"
nodes=""
for attempt in $(seq 1 30); do
  nodes="$(kubectl -n armada get pods -l app=relay --field-selector=status.phase=Running -o jsonpath='{range .items[*]}{.spec.nodeName}{"\n"}{end}' 2>/dev/null | sort -u | grep -c . || true)"
  [ "$nodes" = "2" ] && break
  sleep 4
done
[ "$nodes" = "2" ] || bad "relay pods run on $nodes distinct nodes, expected 2"

if [ "$fail" -eq 0 ]; then
  echo "PASS: relay replicas are spread across nodes by a required constraint"
fi
exit "$fail"
