#!/usr/bin/env bash
# Check: kube-proxy metricsBindAddress is the loopback address and the file is otherwise kept
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

conf="$(kubectl -n kube-system get configmap kube-proxy -o jsonpath='{.data.config\.conf}' 2>/dev/null || true)"
kc="$(kubectl -n kube-system get configmap kube-proxy -o jsonpath='{.data.kubeconfig\.conf}' 2>/dev/null || true)"
[ -n "$conf" ] || bad "the key config.conf is missing or empty"
[ -n "$kc" ] || bad "the key kubeconfig.conf was removed"
echo "$conf" | grep -Eq '^metricsBindAddress: *"?(127\.0\.0\.1|localhost|\[::1\]):[0-9]+' || bad "metricsBindAddress is not a loopback address"

if [ "$fail" -eq 0 ]; then
  echo "PASS: kube-proxy metrics stay on the loopback address"
fi
exit "$fail"
