#!/usr/bin/env bash
# Starting state for the Controller Manager Authority playground. Environment only: it creates the workloads
# and the faults. It does not create anything the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"


kubectl apply -f "$DIR/manifests/controller.yaml"

kubectl -n starfleet rollout status deployment/fleet-controller --timeout=240s
echo "[lab] Ready."
