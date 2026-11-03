# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-080/capstone/labs/lab-01
```

Work through the five tasks. Run `astrona submit` after each one.

## Step 1: Fix the Deployments and the credential

Save this as `credentials.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: backup-target-credentials
  namespace: vault
type: Opaque
stringData:
  access-key: AKIA-NOT-A-REAL-KEY
```

Save this as `workloads.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: exporter
  namespace: vault
  labels:
    app: exporter
spec:
  replicas: 1
  selector:
    matchLabels:
      app: exporter
  template:
    metadata:
      labels:
        app: exporter
    spec:
      serviceAccountName: exporter
      containers:
        - name: exporter
          image: busybox:1.37.0
          command: ["sleep", "3600"]
          env:
            - name: ACCESS_KEY
              valueFrom:
                secretKeyRef:
                  name: backup-target-credentials
                  key: access-key
          resources:
            requests:
              cpu: 10m
              memory: 16Mi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: restore
  namespace: vault
  labels:
    app: restore
spec:
  replicas: 1
  selector:
    matchLabels:
      app: restore
  template:
    metadata:
      labels:
        app: restore
    spec:
      serviceAccountName: restore
      containers:
        - name: restore
          image: busybox:1.37.0
          command: ["sleep", "3600"]
          resources:
            requests:
              cpu: 10m
              memory: 16Mi
```

Apply both and remove the key from the ConfigMap:

```sh
kubectl apply -f credentials.yaml
kubectl apply -f workloads.yaml
kubectl -n vault patch configmap backup-target --type=json -p '[{"op":"remove","path":"/data/access-key"}]'
```

## Step 2: Scope the service account and remove the group binding

Save this as `archive-key-reader.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: archive-key-reader
  namespace: vault
rules:
  - apiGroups: [""]
    resources: ["secrets"]
    resourceNames: ["archive-key"]
    verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: backup-ops-archive-key
  namespace: vault
subjects:
  - kind: ServiceAccount
    name: backup-ops
    namespace: vault
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: archive-key-reader
```

Apply it and delete the broad bindings and the ClusterRole:

```sh
kubectl apply -f archive-key-reader.yaml
kubectl delete clusterrolebinding backup-ops-secrets
kubectl -n vault delete rolebinding everyone-secrets
kubectl delete clusterrole backup-secrets
```

## Step 3: Make the Secret immutable

```sh
kubectl -n vault patch secret archive-key --type=merge -p '{"immutable":true}'
```

