# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-050/capstone/labs/lab-01
```

Work through the four tasks. Run `astrona submit` after each one.

## Step 1: Rewrite the three Deployments

Each Deployment needs a restricted-compatible pod template with no host access. Save this as `loader.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: loader
  namespace: dock
  labels:
    app: loader
spec:
  replicas: 1
  selector:
    matchLabels:
      app: loader
  template:
    metadata:
      labels:
        app: loader
    spec:
      serviceAccountName: loader
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: loader
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

Save this as `builder.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: builder
  namespace: dock
  labels:
    app: builder
spec:
  replicas: 1
  selector:
    matchLabels:
      app: builder
  template:
    metadata:
      labels:
        app: builder
    spec:
      serviceAccountName: builder
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: builder
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

Save this as `runner.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: runner
  namespace: dock
  labels:
    app: runner
spec:
  replicas: 1
  selector:
    matchLabels:
      app: runner
  template:
    metadata:
      labels:
        app: runner
    spec:
      serviceAccountName: runner
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: runner
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

Apply them and wait for the rollouts:

```sh
kubectl apply -f loader.yaml -f builder.yaml -f runner.yaml
kubectl -n dock rollout status deployment/loader
kubectl -n dock rollout status deployment/builder
kubectl -n dock rollout status deployment/runner
```

## Step 2: Enforce the restricted standard

Label the namespace after the pods comply:

```sh
kubectl label namespace dock pod-security.kubernetes.io/enforce=restricted --overwrite
```

If a rollout had started after the label with a non-compliant template, the ReplicaSet events would show the rejected pods.

## Step 3: Create the RuntimeClass

Save this as `isolated.yaml`:

```yaml
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: isolated
handler: kata
overhead:
  podFixed:
    memory: 128Mi
scheduling:
  nodeSelector:
    isolation: strong
```

Apply it:

```sh
kubectl apply -f isolated.yaml
```

