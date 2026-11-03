# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-110/module-01/labs/lab-01
```

Work through the four tasks. Run `astrona submit` after each one.

## Step 1: Change the helper and the reader

Save this as `ledger-fix.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: reporter
  namespace: ledger
  labels:
    app: reporter
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reporter
  template:
    metadata:
      labels:
        app: reporter
    spec:
      serviceAccountName: reporter
      containers:
        - name: reporter
          image: busybox:1.37.0
          command: ["sh", "-c", "while true; do cat /data/log.txt > /dev/null 2>&1; sleep 10; done"]
          volumeMounts:
            - name: data
              mountPath: /data
              readOnly: true
          resources:
            requests:
              cpu: 10m
              memory: 16Mi
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: records
            readOnly: true
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: inspector
  namespace: ledger
  labels:
    app: inspector
spec:
  replicas: 1
  selector:
    matchLabels:
      app: inspector
  template:
    metadata:
      labels:
        app: inspector
    spec:
      serviceAccountName: inspector
      containers:
        - name: inspector
          image: busybox:1.37.0
          command: ["sleep", "3600"]
          resources:
            requests:
              cpu: 10m
              memory: 16Mi
```

Apply it and run `astrona submit`:

```sh
kubectl apply -f ledger-fix.yaml
```

The helper `inspector` no longer has a volume, and `reporter` mounts the claim with `readOnly: true`.

## Step 2: Retain the volume

Find the volume behind the claim and patch its reclaim policy:

```sh
PV="$(kubectl -n ledger get pvc records -o jsonpath='{.spec.volumeName}')"
kubectl patch pv "$PV" -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

Run `astrona submit`.

## Step 3: Remove the workload rights of clerk

Save this as `clerk-role.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: clerk
  namespace: ledger
rules:
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: clerk
  namespace: ledger
subjects:
  - kind: ServiceAccount
    name: clerk
    namespace: ledger
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: clerk
```

Apply it and run `astrona submit`:

```sh
kubectl apply -f clerk-role.yaml
```

The new rules replace the old list, so the rights to create pods and Deployments are gone.

