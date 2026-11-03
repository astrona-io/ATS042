#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/urgent-quota.yaml"
kubectl apply -f "$DIR/placement-helper.yaml"
kubectl -n armada set resources deployment/cargo --requests=cpu=50m,memory=8Mi
kubectl -n armada patch deployment relay --type=merge -p '{"spec":{"template":{"spec":{"topologySpreadConstraints":[{"maxSkew":1,"topologyKey":"kubernetes.io/hostname","whenUnsatisfiable":"DoNotSchedule","labelSelector":{"matchLabels":{"app":"relay"}}}]}}}}'
kubectl -n armada rollout status deployment/cargo --timeout=240s
kubectl -n armada rollout status deployment/relay --timeout=240s
sleep 10

echo "[solution] Applied."
