#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/ledger-fix.yaml"
kubectl apply -f "$DIR/clerk-role.yaml"
PV="$(kubectl -n ledger get pvc records -o jsonpath='{.spec.volumeName}')"
kubectl patch pv "$PV" -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
kubectl -n ledger rollout status deployment/inspector --timeout=180s
kubectl -n ledger rollout status deployment/reporter --timeout=180s

echo "[solution] Applied."
