# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-070/module-01/labs/lab-01
```

The reference solution replaces the Deployment and the Role, and labels the namespace.

## Step 1: Harden the Deployment and remove the token

Save this as `relay.yaml`:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: relay
  namespace: hangar
automountServiceAccountToken: false
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: relay
  namespace: hangar
  labels:
    app: relay
spec:
  replicas: 1
  selector:
    matchLabels:
      app: relay
  template:
    metadata:
      labels:
        app: relay
    spec:
      serviceAccountName: relay
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
        seccompProfile:
          type: RuntimeDefault
      automountServiceAccountToken: false
      containers:
        - name: relay
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

Apply it and run `astrona submit`:

```sh
kubectl apply -f relay.yaml
kubectl -n hangar rollout status deployment relay
```

The service account and the pod template both set `automountServiceAccountToken: false`, so the new pod has no token volume.

## Step 2: Reduce the role

Save this as `relay-role.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: relay-role
  namespace: hangar
rules:
  - apiGroups: [""]
    resources: ["configmaps", "secrets"]
    verbs: ["get", "list"]
  - apiGroups: [""]
    resources: ["pods/exec"]
    verbs: ["create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: relay-role
  namespace: hangar
subjects:
  - kind: ServiceAccount
    name: relay
    namespace: hangar
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: relay-role
```

Apply it and run `astrona submit`:

```sh
kubectl apply -f relay-role.yaml
```

## Step 3: Enforce the restricted standard

Label the namespace and run `astrona submit`:

```sh
kubectl label namespace hangar pod-security.kubernetes.io/enforce=restricted --overwrite
```

The label takes effect for new pods only.

