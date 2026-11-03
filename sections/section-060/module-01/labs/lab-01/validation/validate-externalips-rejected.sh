#!/usr/bin/env bash
# Check: a Service with externalIPs is rejected in starfleet and a ClusterIP Service is accepted
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

# try_service <namespace> <type> <externalIP or empty>: sets TRY_OUT and returns the exit code of a server dry run
try_service() {
  local ns="$1" type="$2" ips="$3" f rc
  f="$(mktemp)"
  {
    printf 'apiVersion: v1\nkind: Service\nmetadata:\n  name: policy-probe\n  namespace: %s\nspec:\n  type: %s\n' "$ns" "$type"
    if [ -n "$ips" ]; then printf '  externalIPs: ["%s"]\n' "$ips"; fi
    printf '  selector:\n    app: none\n  ports:\n    - port: 80\n'
  } > "$f"
  TRY_OUT="$(kubectl apply --dry-run=server -f "$f" 2>&1)"
  rc=$?
  rm -f "$f"
  return $rc
}
# rejected_by_policy <namespace> <type> <externalIP or empty>: waits until an admission policy denies the Service
rejected_by_policy() {
  local i
  for i in $(seq 1 10); do
    if ! try_service "$1" "$2" "$3" && echo "$TRY_OUT" | grep -q "denied request"; then return 0; fi
    sleep 2
  done
  return 1
}
# has_ready_endpoint <namespace> <service>: waits for a ready endpoint in the EndpointSlices of the Service
has_ready_endpoint() {
  local i ready
  for i in $(seq 1 40); do
    ready="$(kubectl -n "$1" get endpointslices -l "kubernetes.io/service-name=$2" -o jsonpath='{.items[*].endpoints[*].conditions.ready}' 2>/dev/null || true)"
    case "$ready" in *true*) return 0 ;; esac
    sleep 3
  done
  return 1
}
rejected_by_policy starfleet ClusterIP 203.0.113.50 || bad "a Service with externalIPs is not rejected by a policy in starfleet"
if ! try_service starfleet ClusterIP ""; then bad "an ordinary ClusterIP Service is rejected: $TRY_OUT"; fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: externalIPs are rejected and ClusterIP Services are accepted"
fi
exit "$fail"
