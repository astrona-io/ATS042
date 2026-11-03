#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/team-label.yaml"
kubectl delete clusterrolebinding everyone-edit --ignore-not-found
kubectl delete role release -n orbit --ignore-not-found
kubectl create role release -n orbit --verb=create,update,patch --resource=deployments.apps
kubectl create role pod-reader -n orbit --verb=get,list --resource=pods
kubectl create rolebinding release-bot-pods -n orbit --role=pod-reader --serviceaccount=orbit:release-bot
kubectl delete clusterrolebinding developers-secrets --ignore-not-found
kubectl create rolebinding developers-secrets -n orbit --clusterrole=secret-reader --group=developers
kubectl label namespace orbit pod-security.kubernetes.io/enforce=baseline pod-security.kubernetes.io/warn=restricted --overwrite
sleep 10

echo "[solution] Applied."
