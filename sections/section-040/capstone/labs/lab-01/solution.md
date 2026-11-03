# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-040/capstone/labs/lab-01
```

Work through the four tasks. Run `astrona submit` after each one.

## Step 1: Narrow the auditor

Save this as `node-auditor.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-auditor
rules:
  - apiGroups: [""]
    resources: ["nodes", "nodes/metrics", "nodes/stats"]
    verbs: ["get", "list"]
```

Apply it:

```sh
kubectl apply -f node-auditor.yaml
```

## Step 2: Scope the operator

Replace the cluster-wide binding with a Role in `deck`:

```sh
kubectl delete clusterrolebinding ops-access
kubectl delete clusterrole ops-access
kubectl create role ops-access -n deck --verb=get,list --resource=pods --resource=pods/log
kubectl create role ops-exec -n deck --verb=create --resource=pods/exec
kubectl create rolebinding ops-access -n deck --role=ops-access --serviceaccount=deck:ops
kubectl create rolebinding ops-exec -n deck --role=ops-exec --serviceaccount=deck:ops
```

The two `--resource` flags on one role are accepted by `kubectl create role`.

## Step 3: Limit approval

Delete the binding for every authenticated user and bind the group `pki-admins`:

```sh
kubectl delete clusterrolebinding everyone-approves-csr
kubectl create clusterrolebinding pki-admins-approve --clusterrole=csr-approver --group=pki-admins
```

## Step 4: Remove the host mount

Remove the volume and the mount with a JSON patch, then wait for the rollout:

```sh
kubectl -n deck patch deployment inspector --type=json -p '[{"op":"remove","path":"/spec/template/spec/volumes"},{"op":"remove","path":"/spec/template/spec/containers/0/volumeMounts"}]'
kubectl -n deck rollout status deployment/inspector
```

