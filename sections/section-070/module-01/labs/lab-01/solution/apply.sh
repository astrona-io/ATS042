#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/relay.yaml"
kubectl apply -f "$DIR/relay-role.yaml"
kubectl -n hangar rollout status deployment relay --timeout=120s
kubectl label namespace hangar pod-security.kubernetes.io/enforce=restricted --overwrite
sleep 5

echo "[solution] Applied."
