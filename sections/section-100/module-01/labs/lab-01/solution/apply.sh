#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/ensign-access.yaml"
kubectl apply -f "$DIR/courier-access.yaml"
kubectl certificate approve ensign
kubectl certificate deny intruder
kubectl -n dock delete secret courier-token --ignore-not-found
kubectl delete clusterrolebinding courier-admin --ignore-not-found
CA="$(kubectl -n dock get configmap kube-root-ca.crt -o jsonpath='{.data.ca\.crt}' | base64 | tr -d '\n')"
TMP="$(mktemp)"
cat > "$TMP" <<EOF
apiVersion: v1
kind: Config
clusters:
  - name: dock
    cluster:
      server: https://203.0.113.10:6443
      certificate-authority-data: ${CA}
users:
  - name: runner
    user:
      tokenFile: /var/run/secrets/runner/token
contexts:
  - name: dock
    context:
      cluster: dock
      user: runner
current-context: dock
EOF
kubectl -n dock create secret generic deploy-kubeconfig --from-file=config="$TMP"
kubectl -n dock delete configmap deploy-kubeconfig
rm -f "$TMP"
sleep 5

echo "[solution] Applied."
