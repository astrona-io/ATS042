#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/courier.yaml"
kubectl apply -f "$DIR/sandboxed.yaml"
kubectl -n outpost rollout status deployment/courier --timeout=240s
kubectl label namespace outpost pod-security.kubernetes.io/enforce=baseline --overwrite
sleep 3

echo "[solution] Applied."
