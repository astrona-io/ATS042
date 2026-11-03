#!/usr/bin/env bash
# Check: ops can exec only in deck and cannot attach or port-forward
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

expect_allowed "create pods/exec in deck" deck ops create pods/exec -n deck
expect_allowed "get pods/log in deck" deck ops get pods/log -n deck
expect_denied "create pods/exec in kube-system" deck ops create pods/exec -n kube-system
expect_denied "create pods/exec in default" deck ops create pods/exec -n default
expect_denied "create pods/attach in deck" deck ops create pods/attach -n deck
expect_denied "create pods/portforward in deck" deck ops create pods/portforward -n deck
expect_denied "list pods in kube-system" deck ops list pods -n kube-system

if [ "$fail" -eq 0 ]; then
  echo "PASS: ops can exec only in deck"
fi
exit "$fail"
