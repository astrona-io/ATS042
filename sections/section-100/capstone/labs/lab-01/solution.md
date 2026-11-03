# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-100/capstone/labs/lab-01
```

Work through the five tasks. Run `astrona submit` after each one.

## Step 1: Decide the requests

Read the subject of each request, then approve and deny:

```sh
kubectl get csr pilot -o jsonpath='{.spec.request}' | base64 --decode | openssl req -noout -subject
kubectl get csr pilot-root -o jsonpath='{.spec.request}' | base64 --decode | openssl req -noout -subject
kubectl certificate approve pilot
kubectl certificate deny pilot-root
```

## Step 2: Grant access through the group

Save this as `flight-access.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployment-viewer
  namespace: deck
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: flight-deployments
  namespace: deck
subjects:
  - kind: Group
    name: flight
    apiGroup: rbac.authorization.k8s.io
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: deployment-viewer
```

Apply it:

```sh
kubectl apply -f flight-access.yaml
```

The subject is the group `flight`, which is the organization entry of the certificate.

## Step 3: Narrow the loader account

Save this as `loader-access.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployment-patcher
  namespace: deck
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: loader-deployments
  namespace: deck
subjects:
  - kind: ServiceAccount
    name: loader
    namespace: deck
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: deployment-patcher
```

Apply it and remove the old credentials:

```sh
kubectl apply -f loader-access.yaml
kubectl -n deck delete secret loader-token
kubectl delete clusterrolebinding loader-admin
```

## Step 4: Move the kubeconfig to a Secret

Collect the certificate authority from the ConfigMap that every namespace has, and write the new file. Save this as `ci.kubeconfig`, and replace `AUTHORITY` with the output of the first command:

```sh
kubectl -n deck get configmap kube-root-ca.crt -o jsonpath='{.data.ca\.crt}' | base64 | tr -d '\n'
```

```yaml
apiVersion: v1
kind: Config
clusters:
  - name: deck
    cluster:
      server: https://203.0.113.10:6443
      certificate-authority-data: AUTHORITY
users:
  - name: runner
    user:
      tokenFile: /var/run/secrets/runner/token
contexts:
  - name: deck
    context:
      cluster: deck
      user: runner
current-context: deck
```

Create the Secret and remove the ConfigMap, then run `astrona submit`:

```sh
kubectl -n deck create secret generic ci-kubeconfig --from-file=config=ci.kubeconfig
kubectl -n deck delete configmap ci-kubeconfig
```

