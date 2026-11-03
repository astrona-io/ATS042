#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/node-auditor.yaml"
kubectl delete clusterrolebinding ops-access --ignore-not-found
kubectl delete clusterrole ops-access --ignore-not-found
kubectl create role ops-access -n deck --verb=get,list --resource=pods --resource=pods/log
kubectl create role ops-exec -n deck --verb=create --resource=pods/exec
kubectl create rolebinding ops-access -n deck --role=ops-access --serviceaccount=deck:ops
kubectl create rolebinding ops-exec -n deck --role=ops-exec --serviceaccount=deck:ops
kubectl delete clusterrolebinding everyone-approves-csr --ignore-not-found
kubectl create clusterrolebinding pki-admins-approve --clusterrole=csr-approver --group=pki-admins
kubectl -n deck patch deployment inspector --type=json -p '[{"op":"remove","path":"/spec/template/spec/volumes"},{"op":"remove","path":"/spec/template/spec/containers/0/volumeMounts"}]'
kubectl -n deck rollout status deployment/inspector --timeout=240s
sleep 5

echo "[solution] Applied."
