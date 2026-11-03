#!/usr/bin/env bash
# Check: every Service in lane is ClusterIP without externalIPs or node ports
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

names="$(kubectl -n lane get services -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || true)"
for s in cargo beacon; do
  case " $names " in *" $s "*) ;; *) bad "the Service $s is missing" ;; esac
done
for s in $names; do
  type="$(kubectl -n lane get service "$s" -o jsonpath='{.spec.type}')"
  ips="$(kubectl -n lane get service "$s" -o jsonpath='{.spec.externalIPs}')"
  np="$(kubectl -n lane get service "$s" -o jsonpath='{.spec.ports[*].nodePort}')"
  [ "$type" = "ClusterIP" ] || bad "$s has type '$type'"
  [ -z "$ips" ] || bad "$s still sets externalIPs"
  [ -z "$np" ] || bad "$s still holds a node port"
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: every Service in lane is ClusterIP"
fi
exit "$fail"
