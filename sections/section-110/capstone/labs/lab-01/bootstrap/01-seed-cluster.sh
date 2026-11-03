#!/usr/bin/env bash
# Starting state for Secure The Depot Storage. Environment only: it creates the workloads
# and the faults. It does not create anything the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"


kubectl apply -f "$DIR/manifests/lab-start.yaml"

kubectl -n depot rollout status deployment/writer --timeout=240s
kubectl -n depot rollout status deployment/auditor --timeout=240s
kubectl -n depot rollout status deployment/scanner --timeout=240s
echo "[lab] Ready."
