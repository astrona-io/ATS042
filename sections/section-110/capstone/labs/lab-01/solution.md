# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-110/capstone/labs/lab-01
```

Work through the five tasks. Run `astrona submit` after each one.

## Step 1: Remove the host path and make the reader read-only

Save this as `depot-fix.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: auditor
  namespace: depot
  labels:
    app: auditor
spec:
  replicas: 1
  selector:
    matchLabels:
      app: auditor
  template:
    metadata:
      labels:
        app: auditor
    spec:
      serviceAccountName: auditor
      containers:
        - name: auditor
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
            claimName: manifest
            readOnly: true
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scanner
  namespace: depot
  labels:
    app: scanner
spec:
  replicas: 1
  selector:
    matchLabels:
      app: scanner
  template:
    metadata:
      labels:
        app: scanner
    spec:
      serviceAccountName: scanner
      containers:
        - name: scanner
          image: busybox:1.37.0
          command: ["sleep", "3600"]
          resources:
            requests:
              cpu: 10m
              memory: 16Mi
```

Apply it:

```sh
kubectl apply -f depot-fix.yaml
```

## Step 2: Enforce the baseline profile

Label the namespace. The profile `baseline` rejects host path volumes:

```sh
kubectl label namespace depot pod-security.kubernetes.io/enforce=baseline --overwrite
```

The fixed Deployments no longer use a host path, so they stay admitted.

## Step 3: Retain the volume

```sh
PV="$(kubectl -n depot get pvc manifest -o jsonpath='{.spec.volumeName}')"
kubectl patch pv "$PV" -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

## Step 4: Remove the workload rights of intern

Save this as `intern-role.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: intern
  namespace: depot
rules:
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: intern
  namespace: depot
subjects:
  - kind: ServiceAccount
    name: intern
    namespace: depot
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: intern
```

Apply it:

```sh
kubectl apply -f intern-role.yaml
```

