#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/credentials.yaml"
kubectl apply -f "$DIR/workloads.yaml"
kubectl apply -f "$DIR/archive-key-reader.yaml"
kubectl -n vault patch configmap backup-target --type=json -p '[{"op":"remove","path":"/data/access-key"}]'
kubectl delete clusterrolebinding backup-ops-secrets --ignore-not-found
kubectl -n vault delete rolebinding everyone-secrets --ignore-not-found
kubectl delete clusterrole backup-secrets --ignore-not-found
kubectl -n vault patch secret archive-key --type=merge -p '{"immutable":true}'
kubectl -n vault rollout status deployment exporter --timeout=120s
kubectl -n vault rollout status deployment restore --timeout=120s
sleep 5

echo "[solution] Applied."
