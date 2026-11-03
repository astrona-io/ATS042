#!/usr/bin/env bash
# Starting state for Remove Host Access And Enforce A Pod Security Level. Environment only: it creates the workloads
# and the faults. It does not create anything the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"


kubectl apply -f "$DIR/manifests/lab-start.yaml"

kubectl -n outpost rollout status deployment/courier --timeout=240s
echo "[lab] Ready."
