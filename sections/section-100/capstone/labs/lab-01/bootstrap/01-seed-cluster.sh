#!/usr/bin/env bash
# Starting state for Rotate Access For A Flight Crew. Environment only: it creates the workloads
# and the faults. It does not create anything the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"


kubectl apply -f "$DIR/manifests/lab-start.yaml"

kubectl -n deck rollout status deployment/hold --timeout=240s
echo "[lab] Ready."
