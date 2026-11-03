#!/usr/bin/env bash
# Starting state for Protect A Backup Namespace. Environment only: it creates the workloads
# and the faults. It does not create anything the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"


kubectl apply -f "$DIR/manifests/lab-start.yaml"

kubectl -n vault rollout status deployment/exporter --timeout=240s
kubectl -n vault rollout status deployment/restore --timeout=240s
echo "[lab] Ready."
