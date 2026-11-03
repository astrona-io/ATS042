#!/usr/bin/env bash
# Check: the kubeconfig is a Secret that verifies the server
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

# csr_conditions <name>: prints the condition types of a CertificateSigningRequest
csr_conditions() { kubectl get csr "$1" -o jsonpath='{.status.conditions[*].type}' 2>/dev/null || true; }
# expect_approved <name>: the request must be Approved and carry a signed certificate
expect_approved() {
  local n="$1" i c cert
  for i in $(seq 1 20); do
    c="$(csr_conditions "$n")"
    cert="$(kubectl get csr "$n" -o jsonpath='{.status.certificate}' 2>/dev/null || true)"
    case " $c " in *" Approved "*) [ -n "$cert" ] && return 0 ;; esac
    sleep 3
  done
  bad "csr $n is not approved with an issued certificate (conditions: '$c')"
}
# expect_csr_denied <name>: the request must be Denied and never Approved
expect_csr_denied() {
  local n="$1" c
  c="$(csr_conditions "$n")"
  case " $c " in *" Denied "*) ;; *) bad "csr $n is not denied (conditions: '$c')" ;; esac
  case " $c " in *" Approved "*) bad "csr $n is approved" ;; esac
}
# can_user <user> <group> <answer> <can-i args>: compares the answer of can-i for a user and group
can_user() {
  local u="$1" g="$2" want="$3" ans; shift 3
  if [ -n "$g" ]; then
    ans="$(kubectl auth can-i "$@" --as="$u" --as-group="$g" 2>/dev/null || true)"
  else
    ans="$(kubectl auth can-i "$@" --as="$u" 2>/dev/null || true)"
  fi
  [ "$ans" = "$want" ] || bad "can-i $* as $u (group '$g') is '$ans', expected '$want'"
}
# secret_config <namespace> <secret>: prints the decoded key config of a Secret
secret_config() {
  local raw
  raw="$(kubectl -n "$1" get secret "$2" -o jsonpath='{.data.config}' 2>/dev/null || true)"
  printf '%s' "$raw" | base64 -d 2>/dev/null || printf '%s' "$raw" | base64 -D 2>/dev/null || true
}
# kubeconfig_ok <namespace> <name>: the kubeconfig moved to a Secret, verifies the server and holds no credential text
kubeconfig_ok() {
  local ns="$1" name="$2" cfg ca
  if kubectl -n "$ns" get configmap "$name" >/dev/null 2>&1; then bad "the ConfigMap $name still exists"; fi
  cfg="$(secret_config "$ns" "$name")"
  [ -n "$cfg" ] || { bad "Secret $name has no key config"; return; }
  ca="$(kubectl -n "$ns" get configmap kube-root-ca.crt -o jsonpath='{.data.ca\.crt}' 2>/dev/null | base64 | tr -d '\n')"
  printf '%s\n' "$cfg" | grep -Eq '^[[:space:]]*server:[[:space:]]*https://' || bad "the kubeconfig has no https server"
  if printf '%s\n' "$cfg" | grep -Eq 'insecure-skip-tls-verify:[[:space:]]*true'; then bad "the kubeconfig still skips TLS verification"; fi
  printf '%s\n' "$cfg" | grep -Fq "certificate-authority-data: $ca" || bad "the kubeconfig does not embed the cluster certificate authority"
  if printf '%s\n' "$cfg" | grep -Eq '^[[:space:]]*(token|exec):'; then bad "the kubeconfig still embeds a token or an exec plugin"; fi
  printf '%s\n' "$cfg" | grep -Eq '^[[:space:]]*tokenFile:' || bad "the kubeconfig does not read the token from a tokenFile"
}
kubeconfig_ok dock deploy-kubeconfig

if [ "$fail" -eq 0 ]; then
  echo "PASS: the kubeconfig is a Secret with verification on and no embedded token"
fi
exit "$fail"
