#!/usr/bin/env bash
# Starting state for Isolate Workloads With NetworkPolicy. Environment only: it creates the workloads
# and the faults. It does not create anything the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"


kubectl apply -f "$DIR/manifests/starfleet.yaml"
kubectl apply -f "$DIR/manifests/lab-start.yaml"

kubectl -n starfleet rollout status deployment/probe --timeout=240s
kubectl -n starfleet rollout status deployment/scout --timeout=240s
kubectl -n starfleet rollout status deployment/shuttle --timeout=240s
kubectl -n starfleet rollout status deployment/visitor --timeout=240s
kubectl -n outpost rollout status deployment/drifter --timeout=240s
kubectl -n outpost rollout status deployment/beacon --timeout=240s
echo "[lab] Ready."
