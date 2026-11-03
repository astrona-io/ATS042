# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-030/capstone/labs/lab-01
```

Work through the four tasks. Run `astrona submit` after each one.

## Step 1: Fix the request

The pods of `cargo` ask for 64 CPUs, and no node has that much. Read the event, then lower the request:

```sh
kubectl -n armada describe pod -l app=cargo
kubectl -n armada set resources deployment/cargo --requests=cpu=50m,memory=8Mi
kubectl -n armada rollout status deployment/cargo
```

## Step 2: Spread the replicas

Patch the pod template with a topology spread constraint over the hostname label:

```sh
kubectl -n armada patch deployment relay --type=merge -p '{"spec":{"template":{"spec":{"topologySpreadConstraints":[{"maxSkew":1,"topologyKey":"kubernetes.io/hostname","whenUnsatisfiable":"DoNotSchedule","labelSelector":{"matchLabels":{"app":"relay"}}}]}}}}'
kubectl -n armada rollout status deployment/relay
```

## Step 3: Limit the priority class

Save this as `urgent-quota.yaml`:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: no-urgent
  namespace: armada
spec:
  hard:
    pods: "0"
  scopeSelector:
    matchExpressions:
      - scopeName: PriorityClass
        operator: In
        values: ["urgent"]
```

Apply it:

```sh
kubectl apply -f urgent-quota.yaml
```

## Step 4: Trim the role

Save this as `placement-helper.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: placement-helper
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
```

Apply it:

```sh
kubectl apply -f placement-helper.yaml
```

