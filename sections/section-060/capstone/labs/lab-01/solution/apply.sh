#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/service-editor.yaml"
kubectl apply -f "$DIR/lane-policy.yaml"
for s in cargo beacon; do
  kubectl -n lane patch service "$s" --type=merge -p '{"spec":{"type":"ClusterIP","externalIPs":null,"ports":[{"name":"http","port":80,"targetPort":"http","protocol":"TCP"}]}}'
done
kubectl delete clusterrolebinding lane-ops-editor --ignore-not-found
kubectl delete clusterrole lane-editor --ignore-not-found
sleep 5

echo "[solution] Applied."
