# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-100/module-01/labs/lab-01
```

Work through the four tasks. Run `astrona submit` after each one.

## Step 1: Decide the certificate requests

Print the subject of each request:

```sh
kubectl get csr ensign -o jsonpath='{.spec.request}' | base64 --decode | openssl req -noout -subject
kubectl get csr intruder -o jsonpath='{.spec.request}' | base64 --decode | openssl req -noout -subject
```

The request `intruder` asks for the group `system:masters`, which the default cluster-admin binding trusts. Approve one and deny the other, then run `astrona submit`:

```sh
kubectl certificate approve ensign
kubectl certificate deny intruder
```

## Step 2: Give ensign read access to pods

Save this as `ensign-access.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-viewer
  namespace: dock
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ensign-pods
  namespace: dock
subjects:
  - kind: User
    name: ensign
    apiGroup: rbac.authorization.k8s.io
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pod-viewer
```

Apply it and run `astrona submit`:

```sh
kubectl apply -f ensign-access.yaml
```

## Step 3: Narrow the courier account

Save this as `courier-access.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: courier-pods
  namespace: dock
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: courier-pods
  namespace: dock
subjects:
  - kind: ServiceAccount
    name: courier
    namespace: dock
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: courier-pods
```

Apply it and remove the old credentials, then run `astrona submit`:

```sh
kubectl apply -f courier-access.yaml
kubectl -n dock delete secret courier-token
kubectl delete clusterrolebinding courier-admin
```

## Step 4: Move the kubeconfig to a Secret

Collect the certificate authority from the ConfigMap that every namespace has, and write the new file. Save this as `deploy.kubeconfig`, and replace `AUTHORITY` with the output of the first command:

```sh
kubectl -n dock get configmap kube-root-ca.crt -o jsonpath='{.data.ca\.crt}' | base64 | tr -d '\n'
```

```yaml
apiVersion: v1
kind: Config
clusters:
  - name: dock
    cluster:
      server: https://203.0.113.10:6443
      certificate-authority-data: AUTHORITY
users:
  - name: runner
    user:
      tokenFile: /var/run/secrets/runner/token
contexts:
  - name: dock
    context:
      cluster: dock
      user: runner
current-context: dock
```

Create the Secret and remove the ConfigMap, then run `astrona submit`:

```sh
kubectl -n dock create secret generic deploy-kubeconfig --from-file=config=deploy.kubeconfig
kubectl -n dock delete configmap deploy-kubeconfig
```

