#!/usr/bin/env bash
# Starting state for Close Service Exposure And Endpoint Write Rights. Environment only: it creates the workloads
# and the faults. It does not create anything the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"


kubectl apply -f "$DIR/manifests/lab-start.yaml"
tmp="$(mktemp)"
conf="$(kubectl -n kube-system get configmap kube-proxy -o jsonpath='{.data.config\.conf}')"
{ printf '%s\n' "$conf" | grep -v '^metricsBindAddress:' || true; echo 'metricsBindAddress: 0.0.0.0:10249'; } > "$tmp"
kubectl create configmap kube-proxy --from-file=config.conf="$tmp" --dry-run=client -o yaml | kubectl -n kube-system apply -f -
rm -f "$tmp"

kubectl -n starfleet rollout status deployment/probe --timeout=240s
echo "[lab] Ready."
