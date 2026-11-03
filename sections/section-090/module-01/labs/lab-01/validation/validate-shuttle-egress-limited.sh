#!/usr/bin/env bash
# Check: shuttle reaches probe and scout by name and nothing else
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

# code_of <namespace> <deployment> <url>: prints the HTTP status code that a request from the Pod returns, 000 when it fails
code_of() { kubectl -n "$1" exec "deploy/$2" -- curl -s --max-time 3 -o /dev/null -w '%{http_code}' "$3" 2>/dev/null || true; }
# expect_reach <namespace> <deployment> <url>: the request must return 200 within about 40 seconds
expect_reach() {
  local i c
  for i in $(seq 1 10); do
    c="$(code_of "$1" "$2" "$3")"
    if [ "$c" = "200" ]; then return 0; fi
    sleep 3
  done
  bad "$1/$2 cannot reach $3 (last status '$c')"
}
# expect_blocked <namespace> <deployment> <url>: the request must fail with 000 within about 40 seconds
expect_blocked() {
  local i c
  for i in $(seq 1 10); do
    c="$(code_of "$1" "$2" "$3")"
    if [ "$c" = "000" ]; then return 0; fi
    sleep 3
  done
  bad "$1/$2 can still reach $3 (last status '$c')"
}
kinds="$(kubectl -n starfleet get networkpolicy -o jsonpath='{range .items[*]}{.spec.podSelector}{"|"}{.spec.policyTypes}{"\n"}{end}' 2>/dev/null || true)"
echo "$kinds" | grep -Eq 'shuttle.*Egress' || bad "no NetworkPolicy restricts the egress of shuttle"
expect_reach starfleet shuttle http://probe.starfleet.svc/get
expect_reach starfleet shuttle http://scout.starfleet.svc/healthz
expect_blocked starfleet shuttle http://beacon.outpost.svc/get

if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle egress is restricted and DNS works"
fi
exit "$fail"
