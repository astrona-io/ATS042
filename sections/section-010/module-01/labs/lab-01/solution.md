# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-010/module-01/labs/lab-01
```

The reference solution uses a Role, a RoleBinding and an admission policy.

## Step 1: Remove the anonymous grant

Find who gets access:

```sh
kubectl get clusterrolebindings -o wide | grep unauthenticated
kubectl delete clusterrolebinding public-reader
```

Check the result as an anonymous caller:

```sh
kubectl auth can-i list pods -n starfleet --as=system:anonymous --as-group=system:unauthenticated
```

The answer must be `no`. Run `astrona submit`.

## Step 2: Give ci-deployer a Role

Delete the cluster-admin binding, then create a Role and a RoleBinding in `starfleet`:

```sh
kubectl delete clusterrolebinding ci-deployer-admin
kubectl create role deployment-manager -n starfleet --verb=get,list,watch,create,update,patch --resource=deployments.apps
kubectl create rolebinding ci-deployer-deployment-manager -n starfleet --role=deployment-manager --serviceaccount=starfleet:ci-deployer
```

Check one allowed and one forbidden verb:

```sh
kubectl auth can-i patch deployments.apps -n starfleet --as=system:serviceaccount:starfleet:ci-deployer
kubectl auth can-i delete deployments.apps -n starfleet --as=system:serviceaccount:starfleet:ci-deployer
```

The first answer is `yes` and the second is `no`. Run `astrona submit`.

## Step 3: Reject privileged pods in outpost

Save the policy and the binding as `deny-privileged.yaml`:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: deny-privileged
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["pods"]
  validations:
    - expression: "object.spec.containers.all(c, !has(c.securityContext) || !has(c.securityContext.privileged) || c.securityContext.privileged == false)"
      message: "privileged containers are not allowed"
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: deny-privileged-outpost
spec:
  policyName: deny-privileged
  validationActions: ["Deny"]
  matchResources:
    namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: outpost
```

Apply it:

```sh
kubectl apply -f deny-privileged.yaml
```

The policy needs a few seconds to take effect. Run `astrona submit` again if the check fails at first.

## Step 4: Stop the token mount

Set the field on the service account and restart the Deployment so new pods are created:

```sh
kubectl patch serviceaccount probe -n starfleet -p '{"automountServiceAccountToken": false}'
kubectl rollout restart deployment/probe -n starfleet
kubectl rollout status deployment/probe -n starfleet
```

Run `astrona submit`. All checks pass.

