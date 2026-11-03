#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/role-manager.yaml"
kubectl delete clusterrolebinding fleet-controller --ignore-not-found
kubectl delete clusterrole fleet-controller --ignore-not-found
kubectl create role configmap-reader -n starfleet --verb=get,list,watch --resource=configmaps
kubectl create role state-writer -n starfleet --verb=update,patch --resource=configmaps --resource-name=fleet-state
kubectl create rolebinding fleet-controller-read -n starfleet --role=configmap-reader --serviceaccount=starfleet:fleet-controller
kubectl create rolebinding fleet-controller-write -n starfleet --role=state-writer --serviceaccount=starfleet:fleet-controller
uid_value="$(kubectl get deployment fleet-controller -n starfleet -o jsonpath='{.metadata.uid}')"
kubectl patch configmap fleet-state -n starfleet --type=merge -p "{\"metadata\":{\"ownerReferences\":[{\"apiVersion\":\"apps/v1\",\"kind\":\"Deployment\",\"name\":\"fleet-controller\",\"uid\":\"${uid_value}\"}]}}"

echo "[solution] Applied."
