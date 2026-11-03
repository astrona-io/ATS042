# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-060/capstone/labs/lab-01
```

Work through the four tasks. Run `astrona submit` after each one.

## Step 1: Convert the Services

Patch both Services so the node ports and external addresses are dropped:

```sh
kubectl -n lane patch service cargo --type=merge -p '{"spec":{"type":"ClusterIP","externalIPs":null,"ports":[{"name":"http","port":80,"targetPort":"http","protocol":"TCP"}]}}'
kubectl -n lane patch service beacon --type=merge -p '{"spec":{"type":"ClusterIP","externalIPs":null,"ports":[{"name":"http","port":80,"targetPort":"http","protocol":"TCP"}]}}'
```

## Step 2: Scope the service account

Delete the cluster-wide binding and role, then create a Role and a RoleBinding in `lane`. Save this as `service-editor.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: service-editor
  namespace: lane
rules:
  - apiGroups: [""]
    resources: ["services"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: ["discovery.k8s.io"]
    resources: ["endpointslices"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: lane-ops-service-editor
  namespace: lane
subjects:
  - kind: ServiceAccount
    name: lane-ops
    namespace: lane
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: service-editor
```

Apply it and remove the old objects:

```sh
kubectl delete clusterrolebinding lane-ops-editor
kubectl delete clusterrole lane-editor
kubectl apply -f service-editor.yaml
```

## Step 3: Add the admission policy

Save this as `lane-policy.yaml`:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: lane-clusterip-only
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["services"]
  validations:
    - expression: "!has(object.spec.type) || object.spec.type == 'ClusterIP'"
      message: "only ClusterIP Services are allowed here"
    - expression: "!has(object.spec.externalIPs) || size(object.spec.externalIPs) == 0"
      message: "spec.externalIPs must not be set"
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: lane-clusterip-only-lane
spec:
  policyName: lane-clusterip-only
  validationActions: ["Deny"]
  matchResources:
    namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: lane
```

Apply it:

```sh
kubectl apply -f lane-policy.yaml
```

The policy needs a few seconds before it denies requests.

