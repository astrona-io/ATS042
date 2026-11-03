#!/usr/bin/env bash
# Starting state for Reduce Who Can Reach A Volume. Environment only: it creates the workloads
# and the faults. It does not create anything the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"


kubectl apply -f "$DIR/manifests/lab-start.yaml"

kubectl -n ledger rollout status deployment/collector --timeout=240s
kubectl -n ledger rollout status deployment/reporter --timeout=240s
kubectl -n ledger rollout status deployment/inspector --timeout=240s
echo "[lab] Ready."
