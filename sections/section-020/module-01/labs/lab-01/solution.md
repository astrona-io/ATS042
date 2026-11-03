# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-020/module-01/labs/lab-01
```

The reference solution uses a Role with a resourceNames rule, a trimmed ClusterRole and an ownerReference.

## Step 1: Replace the wildcard grant

Delete the cluster-wide binding and the wildcard role, then create two namespaced Roles. One reads ConfigMaps. One updates only `fleet-state`:

```sh
kubectl delete clusterrolebinding fleet-controller
kubectl delete clusterrole fleet-controller
kubectl create role configmap-reader -n starfleet --verb=get,list,watch --resource=configmaps
kubectl create role state-writer -n starfleet --verb=update,patch --resource=configmaps --resource-name=fleet-state
kubectl create rolebinding fleet-controller-read -n starfleet --role=configmap-reader --serviceaccount=starfleet:fleet-controller
kubectl create rolebinding fleet-controller-write -n starfleet --role=state-writer --serviceaccount=starfleet:fleet-controller
```

Check one allowed and one forbidden request:

```sh
kubectl auth can-i patch configmaps/fleet-state -n starfleet --as=system:serviceaccount:starfleet:fleet-controller
kubectl auth can-i get secrets -n starfleet --as=system:serviceaccount:starfleet:fleet-controller
```

The first answer is `yes` and the second is `no`. Run `astrona submit`.

## Step 2: Remove escalate and bind

Save this as `role-manager.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: role-manager
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list"]
```

Apply it:

```sh
kubectl apply -f role-manager.yaml
```

A ClusterRole is changed in place, so the binding `intern-role-manager` now gives only pod read access.

## Step 3: Add the owner reference

Read the Deployment's unique ID and write it into the ConfigMap:

```sh
UID_VALUE=$(kubectl get deployment fleet-controller -n starfleet -o jsonpath='{.metadata.uid}')
kubectl patch configmap fleet-state -n starfleet --type=merge -p "{\"metadata\":{\"ownerReferences\":[{\"apiVersion\":\"apps/v1\",\"kind\":\"Deployment\",\"name\":\"fleet-controller\",\"uid\":\"$UID_VALUE\"}]}}"
```

Run `astrona submit`. All checks pass.

