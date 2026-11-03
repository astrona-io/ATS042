#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/solution.yaml"
kubectl delete clusterrolebinding public-reader --ignore-not-found
kubectl delete clusterrolebinding ci-deployer-admin --ignore-not-found
kubectl create role deployment-manager -n starfleet --verb=get,list,watch,create,update,patch --resource=deployments.apps --dry-run=client -o yaml | kubectl apply -f -
kubectl create rolebinding ci-deployer-deployment-manager -n starfleet --role=deployment-manager --serviceaccount=starfleet:ci-deployer --dry-run=client -o yaml | kubectl apply -f -
kubectl patch serviceaccount probe -n starfleet -p '{"automountServiceAccountToken": false}'
kubectl rollout restart deployment/probe -n starfleet
kubectl rollout status deployment/probe -n starfleet --timeout=240s
sleep 10

echo "[solution] Applied."
