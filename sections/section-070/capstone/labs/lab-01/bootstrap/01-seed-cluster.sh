#!/usr/bin/env bash
# Starting state for Secure A Kitchen Namespace. Environment only: it creates the workloads
# and the faults. It does not create anything the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"


kubectl apply -f "$DIR/manifests/lab-start.yaml"

kubectl -n galley rollout status deployment/pantry --timeout=240s
kubectl -n galley rollout status deployment/oven --timeout=240s
echo "[lab] Ready."
