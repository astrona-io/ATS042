#!/usr/bin/env bash
# Starting state for Segment A Two Namespace Application. Environment only: it creates the workloads
# and the faults. It does not create anything the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"


kubectl apply -f "$DIR/manifests/lab-start.yaml"

kubectl -n bay rollout status deployment/gate --timeout=240s
kubectl -n bay rollout status deployment/crane --timeout=240s
kubectl -n bay rollout status deployment/store --timeout=240s
kubectl -n quay rollout status deployment/auditor --timeout=240s
kubectl -n quay rollout status deployment/stranger --timeout=240s
kubectl -n quay rollout status deployment/lighthouse --timeout=240s
echo "[lab] Ready."
