# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-040/module-01/labs/lab-01
```

The reference solution rewrites one ClusterRole and replaces one binding.

## Step 1: Narrow the monitor role

Save this as `node-monitor.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-monitor
rules:
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["get", "list"]
  - apiGroups: [""]
    resources: ["nodes/metrics", "nodes/stats"]
    verbs: ["get"]
```

Apply it:

```sh
kubectl apply -f node-monitor.yaml
```

Check that `nodes/proxy` is gone:

```sh
kubectl auth can-i get nodes --subresource=proxy --as=system:serviceaccount:starfleet:monitor
```

The answer is `no`. Run `astrona submit`.

## Step 2: Scope the debugger

Delete the cluster-wide binding and bind the same ClusterRole inside `outpost` only:

```sh
kubectl delete clusterrolebinding debugger-pod-debugger
kubectl create rolebinding debugger-pod-debugger -n outpost --clusterrole=pod-debugger --serviceaccount=starfleet:debugger
```

A RoleBinding gives a ClusterRole's rules only inside its own namespace.

## Step 3: Remove approval

Save this as `csr-approver.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: csr-approver
rules:
  - apiGroups: ["certificates.k8s.io"]
    resources: ["certificatesigningrequests"]
    verbs: ["get", "list", "watch"]
```

Apply it and run `astrona submit`:

```sh
kubectl apply -f csr-approver.yaml
```

