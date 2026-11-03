# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-070/capstone/labs/lab-01
```

Work through the four tasks. Run `astrona submit` after each one.

## Step 1: Harden the workloads and remove the tokens

Save this as `workloads.yaml`:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pantry
  namespace: galley
automountServiceAccountToken: false
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: oven
  namespace: galley
automountServiceAccountToken: false
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: chef
  namespace: galley
automountServiceAccountToken: false
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pantry
  namespace: galley
  labels:
    app: pantry
spec:
  replicas: 1
  selector:
    matchLabels:
      app: pantry
  template:
    metadata:
      labels:
        app: pantry
    spec:
      serviceAccountName: pantry
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
        seccompProfile:
          type: RuntimeDefault
      automountServiceAccountToken: false
      containers:
        - name: pantry
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
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: oven
  namespace: galley
  labels:
    app: oven
spec:
  replicas: 1
  selector:
    matchLabels:
      app: oven
  template:
    metadata:
      labels:
        app: oven
    spec:
      serviceAccountName: oven
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
        seccompProfile:
          type: RuntimeDefault
      automountServiceAccountToken: false
      containers:
        - name: oven
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

Apply it:

```sh
kubectl apply -f workloads.yaml
kubectl -n galley rollout status deployment pantry
kubectl -n galley rollout status deployment oven
```

## Step 2: Reduce the operator role

Save this as `chef-role.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: chef-role
  namespace: galley
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["pods/log"]
    verbs: ["get"]
```

Apply it:

```sh
kubectl apply -f chef-role.yaml
```

## Step 3: Enforce the standard

```sh
kubectl label namespace galley pod-security.kubernetes.io/enforce=restricted --overwrite
```

