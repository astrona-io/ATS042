#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/node-labeler.yaml"
kubectl apply -f "$DIR/deny-node-name.yaml"
kubectl -n starfleet patch deployment vault --type=merge -p '{"spec":{"template":{"spec":{"tolerations":[{"key":"tier","operator":"Equal","value":"restricted","effect":"NoSchedule"}]}}}}'
kubectl -n starfleet rollout status deployment/vault --timeout=240s
sleep 10

echo "[solution] Applied."
