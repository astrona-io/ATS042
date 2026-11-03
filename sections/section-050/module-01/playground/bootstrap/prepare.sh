#!/usr/bin/env bash
# Starting state for the Container Runtime Protection playground. Environment only: it creates the workloads
# and the faults. It does not create anything the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"


kubectl apply -f "$DIR/manifests/starfleet.yaml"

kubectl -n starfleet rollout status deployment/scout --timeout=240s
echo "[lab] Ready."
