#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/workloads.yaml"
kubectl apply -f "$DIR/chef-role.yaml"
kubectl -n galley rollout status deployment pantry --timeout=120s
kubectl -n galley rollout status deployment oven --timeout=120s
kubectl label namespace galley pod-security.kubernetes.io/enforce=restricted --overwrite
sleep 5

echo "[solution] Applied."
