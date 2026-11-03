#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/loader.yaml"
kubectl apply -f "$DIR/builder.yaml"
kubectl apply -f "$DIR/runner.yaml"
kubectl apply -f "$DIR/isolated.yaml"
for d in loader builder runner; do
  kubectl -n dock rollout status "deployment/$d" --timeout=240s
done
kubectl label namespace dock pod-security.kubernetes.io/enforce=restricted --overwrite
sleep 3

echo "[solution] Applied."
