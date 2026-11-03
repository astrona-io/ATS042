#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/flight-access.yaml"
kubectl apply -f "$DIR/loader-access.yaml"
kubectl certificate approve pilot
kubectl certificate deny pilot-root
kubectl -n deck delete secret loader-token --ignore-not-found
kubectl delete clusterrolebinding loader-admin --ignore-not-found
CA="$(kubectl -n deck get configmap kube-root-ca.crt -o jsonpath='{.data.ca\.crt}' | base64 | tr -d '\n')"
TMP="$(mktemp)"
cat > "$TMP" <<EOF
apiVersion: v1
kind: Config
clusters:
  - name: deck
    cluster:
      server: https://203.0.113.10:6443
      certificate-authority-data: ${CA}
users:
  - name: runner
    user:
      tokenFile: /var/run/secrets/runner/token
contexts:
  - name: deck
    context:
      cluster: deck
      user: runner
current-context: deck
EOF
kubectl -n deck create secret generic ci-kubeconfig --from-file=config="$TMP"
kubectl -n deck delete configmap ci-kubeconfig
rm -f "$TMP"
sleep 5

echo "[solution] Applied."
