#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/depot-fix.yaml"
kubectl apply -f "$DIR/intern-role.yaml"
kubectl -n depot rollout status deployment/scanner --timeout=180s
kubectl -n depot rollout status deployment/auditor --timeout=180s
kubectl label namespace depot pod-security.kubernetes.io/enforce=baseline --overwrite
PV="$(kubectl -n depot get pvc manifest -o jsonpath='{.spec.volumeName}')"
kubectl patch pv "$PV" -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'

echo "[solution] Applied."
