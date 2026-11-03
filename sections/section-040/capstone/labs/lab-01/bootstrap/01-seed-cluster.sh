#!/usr/bin/env bash
# Starting state for Close Node Access Paths In A Namespace. Environment only: it creates the workloads
# and the faults. It does not create anything the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"


kubectl apply -f "$DIR/manifests/lab-start.yaml"

kubectl -n deck rollout status deployment/inspector --timeout=240s
echo "[lab] Ready."
