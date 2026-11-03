#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


kubectl delete clusterrolebinding ops-operator --ignore-not-found
kubectl delete clusterrole ops-operator --ignore-not-found
kubectl create role operator -n harbor --verb=get,list,watch,update,patch --resource=deployments.apps
kubectl create role operator-config -n harbor --verb=get,list,watch --resource=configmaps
kubectl create rolebinding ops-operator -n harbor --role=operator --serviceaccount=harbor:ops-operator
kubectl create rolebinding ops-operator-config -n harbor --role=operator-config --serviceaccount=harbor:ops-operator
kubectl rollout resume deployment/harbor-web -n harbor
kubectl rollout status deployment/harbor-web -n harbor --timeout=240s
kubectl patch cronjob nightly-backup -n harbor --type=merge -p '{"spec":{"successfulJobsHistoryLimit":2,"jobTemplate":{"spec":{"ttlSecondsAfterFinished":300}}}}'

echo "[solution] Applied."
