#!/usr/bin/env bash
# Starting state for Protect A Restricted Node Pool. Environment only: it creates the workloads
# and the faults. It does not create anything the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

worker="$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}')"
kubectl label node "$worker" tier=restricted --overwrite
kubectl taint node "$worker" tier=restricted:NoSchedule --overwrite

kubectl apply -f "$DIR/manifests/lab-start.yaml"

kubectl -n starfleet rollout status deployment/scout --timeout=240s
echo "[lab] Ready."
