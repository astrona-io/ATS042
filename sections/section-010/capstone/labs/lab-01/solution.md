# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-010/capstone/labs/lab-01
```

Work through the five tasks in order. Run `astrona submit` after each step.

## Step 1: Remove the edit grant

```sh
kubectl delete clusterrolebinding everyone-edit
```

## Step 2: Narrow the release Role

Replace the rules of the Role `release` with the exact rules:

```sh
kubectl delete role release -n orbit
kubectl create role release -n orbit --verb=create,update,patch --resource=deployments.apps
kubectl create role pod-reader -n orbit --verb=get,list --resource=pods
kubectl create rolebinding release-bot -n orbit --role=release --serviceaccount=orbit:release-bot --dry-run=client -o yaml | kubectl apply -f -
kubectl create rolebinding release-bot-pods -n orbit --role=pod-reader --serviceaccount=orbit:release-bot
```

Deleting the Role leaves the RoleBinding `release-bot` in place, and the new Role has the same name, so the binding works again.

## Step 3: Scope the secret reader

Delete the ClusterRoleBinding and bind the same ClusterRole with a RoleBinding in `orbit`:

```sh
kubectl delete clusterrolebinding developers-secrets
kubectl create rolebinding developers-secrets -n orbit --clusterrole=secret-reader --group=developers
```

## Step 4: Require the team label

Save this as `team-label.yaml`:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: require-team-label
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
      - apiGroups: ["apps"]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["deployments"]
  validations:
    - expression: "has(object.metadata.labels) && 'team' in object.metadata.labels"
      message: "a team label is required"
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: require-team-label-orbit
spec:
  policyName: require-team-label
  validationActions: ["Deny"]
  matchResources:
    namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: orbit
```

Apply it:

```sh
kubectl apply -f team-label.yaml
```

## Step 5: Label the namespace

```sh
kubectl label namespace orbit pod-security.kubernetes.io/enforce=baseline pod-security.kubernetes.io/warn=restricted --overwrite
```

