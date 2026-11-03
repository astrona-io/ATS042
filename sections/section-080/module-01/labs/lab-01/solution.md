# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-080/module-01/labs/lab-01
```

The reference solution replaces the Deployment and the RBAC objects, and moves the password.

## Step 1: Move the password to a Secret and remove the host paths

Save this as `snapshot-credentials.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: snapshot-credentials
  namespace: archive
type: Opaque
stringData:
  password: s3cr3t-backup-pass
```

Save this as `snapshotter.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: snapshotter
  namespace: archive
  labels:
    app: snapshotter
spec:
  replicas: 1
  selector:
    matchLabels:
      app: snapshotter
  template:
    metadata:
      labels:
        app: snapshotter
    spec:
      serviceAccountName: snapshotter
      containers:
        - name: snapshotter
          image: busybox:1.37.0
          command: ["sleep", "3600"]
          env:
            - name: BACKUP_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: snapshot-credentials
                  key: password
          resources:
            requests:
              cpu: 10m
              memory: 16Mi
```

Apply both, then remove the password from the ConfigMap and run `astrona submit`:

```sh
kubectl apply -f snapshot-credentials.yaml
kubectl apply -f snapshotter.yaml
kubectl -n archive patch configmap snapshot-settings --type=json -p '[{"op":"remove","path":"/data/password"}]'
kubectl -n archive rollout status deployment snapshotter
```

## Step 2: Narrow the service account

Save this as `backup-key-reader.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: backup-key-reader
  namespace: archive
rules:
  - apiGroups: [""]
    resources: ["secrets"]
    resourceNames: ["backup-key"]
    verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: snapshotter-backup-key
  namespace: archive
subjects:
  - kind: ServiceAccount
    name: snapshotter
    namespace: archive
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: backup-key-reader
```

Apply it and remove the cluster-wide objects, then run `astrona submit`:

```sh
kubectl apply -f backup-key-reader.yaml
kubectl delete clusterrolebinding snapshotter-secrets
```

## Step 3: Remove the group binding

Delete the RoleBinding for authenticated users and the ClusterRole that no longer has a user, then run `astrona submit`:

```sh
kubectl -n archive delete rolebinding authenticated-secrets
kubectl delete clusterrole secret-reader
```

