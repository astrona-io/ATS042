# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-030/module-01/labs/lab-01
```

The reference solution adds a toleration, trims one ClusterRole and adds an admission policy.

## Step 1: Read the scheduling event

Find out why the pod is Pending:

```sh
kubectl -n starfleet describe pod -l app=vault
```

The `FailedScheduling` event says that a node has a taint that the pod does not tolerate. Add a toleration that matches the taint:

```sh
kubectl -n starfleet patch deployment vault --type=merge -p '{"spec":{"template":{"spec":{"tolerations":[{"key":"tier","operator":"Equal","value":"restricted","effect":"NoSchedule"}]}}}}'
kubectl -n starfleet rollout status deployment/vault
```

Run `astrona submit`. The first two checks pass.

## Step 2: Remove node write access

Save this as `node-labeler.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-labeler
rules:
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["get", "list"]
```

Apply it:

```sh
kubectl apply -f node-labeler.yaml
```

## Step 3: Reject pods with nodeName

Save this as `deny-node-name.yaml`:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: deny-node-name
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE"]
        resources: ["pods"]
  validations:
    - expression: "!has(object.spec.nodeName) || object.spec.nodeName == ''"
      message: "pods must be placed by the scheduler: spec.nodeName must not be set"
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: deny-node-name-outpost
spec:
  policyName: deny-node-name
  validationActions: ["Deny"]
  matchResources:
    namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: outpost
```

Apply it, wait a few seconds for the policy to become active and run `astrona submit`:

```sh
kubectl apply -f deny-node-name.yaml
```

