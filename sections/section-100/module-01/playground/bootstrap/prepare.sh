#!/usr/bin/env bash
# Starting state for the Client Credentials And Configuration playground. Environment only: it creates the workloads
# and the faults. It does not create anything the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"


kubectl apply -f "$DIR/manifests/starfleet.yaml"
kubectl apply -f "$DIR/manifests/runner.yaml"

kubectl -n starfleet rollout status deployment/scout --timeout=240s
kubectl -n starfleet rollout status deployment/shuttle --timeout=240s
kubectl -n outpost rollout status deployment/drifter --timeout=240s
echo "[lab] Ready."
