#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/deny-external-ips.yaml"
kubectl apply -f "$DIR/traffic-editor.yaml"
kubectl -n starfleet patch service gateway --type=merge -p '{"spec":{"type":"ClusterIP","externalIPs":null,"ports":[{"name":"http","port":80,"targetPort":"http","protocol":"TCP"}]}}'
tmp="$(mktemp)"
conf="$(kubectl -n kube-system get configmap kube-proxy -o jsonpath='{.data.config\.conf}')"
{ printf '%s\n' "$conf" | grep -v '^metricsBindAddress:' || true; echo 'metricsBindAddress: 127.0.0.1:10249'; } > "$tmp"
kubectl create configmap kube-proxy --from-file=config.conf="$tmp" --dry-run=client -o yaml | kubectl -n kube-system apply -f -
rm -f "$tmp"
sleep 5

echo "[solution] Applied."
