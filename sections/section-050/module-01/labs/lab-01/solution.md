# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-050/module-01/labs/lab-01
```

The reference solution rewrites the Deployment, labels the namespace and creates the RuntimeClass.

## Step 1: Rewrite the Deployment

Save this as `courier.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: courier
  namespace: outpost
  labels:
    app: courier
spec:
  replicas: 1
  selector:
    matchLabels:
      app: courier
  template:
    metadata:
      labels:
        app: courier
    spec:
      serviceAccountName: courier
      containers:
        - name: courier
          image: busybox:1.37.0
          command: ["sleep", "3600"]
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop: ["ALL"]
          resources:
            requests:
              cpu: 10m
              memory: 16Mi
```

Apply it and wait for the rollout:

```sh
kubectl apply -f courier.yaml
kubectl -n outpost rollout status deployment/courier
```

The new pod template has no privileged mode, no host mount, no host process namespace and no added capability. Run `astrona submit`.

## Step 2: Enforce the baseline standard

Label the namespace:

```sh
kubectl label namespace outpost pod-security.kubernetes.io/enforce=baseline --overwrite
```

Ask the server to validate a privileged pod in `outpost` to see the rejection. Run `astrona submit`.

## Step 3: Create the RuntimeClass

Save this as `sandboxed.yaml`:

```yaml
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: sandboxed
handler: runsc
overhead:
  podFixed:
    cpu: 100m
    memory: 64Mi
```

Apply it and run `astrona submit`:

```sh
kubectl apply -f sandboxed.yaml
```

