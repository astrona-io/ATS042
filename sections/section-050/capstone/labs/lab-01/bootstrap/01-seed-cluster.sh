#!/usr/bin/env bash
# Starting state for Harden A Build Namespace. Environment only: it creates the workloads
# and the faults. It does not create anything the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"


kubectl apply -f "$DIR/manifests/lab-start.yaml"

kubectl -n dock rollout status deployment/loader --timeout=240s
kubectl -n dock rollout status deployment/builder --timeout=240s
kubectl -n dock rollout status deployment/runner --timeout=240s
echo "[lab] Ready."
