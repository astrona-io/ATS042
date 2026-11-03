# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-020/capstone/labs/lab-01
```

Work through the four tasks. Run `astrona submit` after each one.

## Step 1: Scope the operator

Remove the cluster-wide grant and bind a Role in `harbor`:

```sh
kubectl delete clusterrolebinding ops-operator
kubectl delete clusterrole ops-operator
kubectl create role operator -n harbor --verb=get,list,watch,update,patch --resource=deployments.apps
kubectl create role operator-config -n harbor --verb=get,list,watch --resource=configmaps
kubectl create rolebinding ops-operator -n harbor --role=operator --serviceaccount=harbor:ops-operator
kubectl create rolebinding ops-operator-config -n harbor --role=operator-config --serviceaccount=harbor:ops-operator
```

## Step 2: Check Secrets and escalation

Deleting the ClusterRole already removed the Secret, `escalate` and `bind` rules. Prove it:

```sh
kubectl auth can-i get secrets -n harbor --as=system:serviceaccount:harbor:ops-operator
kubectl auth can-i escalate clusterroles.rbac.authorization.k8s.io --as=system:serviceaccount:harbor:ops-operator
```

Both answers are `no`.

## Step 3: Resume the Deployment

A paused Deployment is not reconciled. Resume it and wait:

```sh
kubectl rollout resume deployment/harbor-web -n harbor
kubectl rollout status deployment/harbor-web -n harbor
```

## Step 4: Clean up Jobs

Set the history limit and the time to live in the Job template:

```sh
kubectl patch cronjob nightly-backup -n harbor --type=merge -p '{"spec":{"successfulJobsHistoryLimit":2,"jobTemplate":{"spec":{"ttlSecondsAfterFinished":300}}}}'
```

