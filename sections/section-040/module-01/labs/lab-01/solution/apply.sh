#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/node-monitor.yaml"
kubectl apply -f "$DIR/csr-approver.yaml"
kubectl delete clusterrolebinding debugger-pod-debugger --ignore-not-found
kubectl create rolebinding debugger-pod-debugger -n outpost --clusterrole=pod-debugger --serviceaccount=starfleet:debugger --dry-run=client -o yaml | kubectl apply -f -
sleep 5

echo "[solution] Applied."
