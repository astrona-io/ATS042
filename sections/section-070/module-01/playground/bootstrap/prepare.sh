#!/usr/bin/env bash
# Starting state for the Pod Execution And Credential Boundaries playground. Environment only: it creates the workloads
# and the faults. It does not create anything the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"


kubectl apply -f "$DIR/manifests/starfleet.yaml"
kubectl apply -f "$DIR/manifests/crew.yaml"

kubectl -n starfleet rollout status deployment/shuttle --timeout=240s
echo "[lab] Ready."
