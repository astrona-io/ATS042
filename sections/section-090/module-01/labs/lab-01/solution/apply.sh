#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/probe-ingress.yaml"
kubectl apply -f "$DIR/scout-ingress.yaml"
kubectl apply -f "$DIR/shuttle-egress.yaml"
sleep 15

echo "[solution] Applied."
