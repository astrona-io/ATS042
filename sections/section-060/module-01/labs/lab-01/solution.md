# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-060/module-01/labs/lab-01
```

The reference solution patches the Service, adds a policy, reduces one role and edits one ConfigMap.

## Step 1: Make gateway a ClusterIP Service

Replace the ports so that the old node port is dropped, and clear `externalIPs`:

```sh
kubectl -n starfleet patch service gateway --type=merge -p '{"spec":{"type":"ClusterIP","externalIPs":null,"ports":[{"name":"http","port":80,"targetPort":"http","protocol":"TCP"}]}}'
```

Read the Service back with `kubectl -n starfleet get service gateway -o yaml`. Run `astrona submit`.

## Step 2: Reject externalIPs

Save this as `deny-external-ips.yaml`:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: deny-external-ips
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["services"]
  validations:
    - expression: "!has(object.spec.externalIPs) || size(object.spec.externalIPs) == 0"
      message: "spec.externalIPs must not be set"
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: deny-external-ips-starfleet
spec:
  policyName: deny-external-ips
  validationActions: ["Deny"]
  matchResources:
    namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: starfleet
```

Apply it and run `astrona submit`:

```sh
kubectl apply -f deny-external-ips.yaml
```

A new policy can take a few seconds to become active.

## Step 3: Reduce the intern role

Save this as `traffic-editor.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: traffic-editor
rules:
  - apiGroups: [""]
    resources: ["services", "endpoints"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["discovery.k8s.io"]
    resources: ["endpointslices"]
    verbs: ["get", "list", "watch"]
```

Apply it and run `astrona submit`:

```sh
kubectl apply -f traffic-editor.yaml
```

The ClusterRole is rewritten, so the existing binding now grants read access only.

## Step 4: Bind the metrics address to the loopback interface

Open the ConfigMap in an editor:

```sh
kubectl -n kube-system edit configmap kube-proxy
```

In the key `config.conf`, set `metricsBindAddress: 127.0.0.1:10249`. Save and exit, then run `astrona submit`. The kube-proxy pods read the file when they restart, and this lab does not restart them.

