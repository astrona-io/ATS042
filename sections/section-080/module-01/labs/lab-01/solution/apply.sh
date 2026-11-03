#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/snapshot-credentials.yaml"
kubectl apply -f "$DIR/snapshotter.yaml"
kubectl apply -f "$DIR/backup-key-reader.yaml"
kubectl -n archive patch configmap snapshot-settings --type=json -p '[{"op":"remove","path":"/data/password"}]'
kubectl delete clusterrolebinding snapshotter-secrets --ignore-not-found
kubectl -n archive delete rolebinding authenticated-secrets --ignore-not-found
kubectl delete clusterrole secret-reader --ignore-not-found
kubectl -n archive rollout status deployment snapshotter --timeout=120s
sleep 5

echo "[solution] Applied."
