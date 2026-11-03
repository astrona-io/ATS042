#!/usr/bin/env bash
# Check: The probe pods do not mount a service account token
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

value="$(kubectl get serviceaccount probe -n starfleet -o jsonpath='{.automountServiceAccountToken}' 2>/dev/null || true)"
[ "$value" = "false" ] || bad "the probe service account still automounts its token"
pods="$(kubectl get pods -n starfleet -l app=probe -o name 2>/dev/null || true)"
[ -n "$pods" ] || bad "no probe pod found"
for pod in $pods; do
  volumes="$(kubectl get "$pod" -n starfleet -o jsonpath='{.spec.volumes[*].name}' 2>/dev/null || true)"
  case "$volumes" in
    *kube-api-access*) bad "$pod still has a kube-api-access token volume" ;;
  esac
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: the probe pod has no service account token volume"
fi
exit "$fail"
