# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-090/capstone/labs/lab-01
```

Work through the five tasks. Run `astrona submit` after each one.

## Step 1: Write the policies of bay

Save this as `bay-policies.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: bay
spec:
  podSelector: {}
  policyTypes: ["Ingress"]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: gate-ingress
  namespace: bay
spec:
  podSelector:
    matchLabels:
      app: gate
  policyTypes: ["Ingress"]
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: crane
      ports:
        - protocol: TCP
          port: 8080
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: store-ingress
  namespace: bay
spec:
  podSelector:
    matchLabels:
      app: store
  policyTypes: ["Ingress"]
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: crane
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: quay
          podSelector:
            matchLabels:
              app: auditor
      ports:
        - protocol: TCP
          port: 9898
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: crane-egress
  namespace: bay
spec:
  podSelector:
    matchLabels:
      app: crane
  policyTypes: ["Egress"]
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
          podSelector:
            matchLabels:
              k8s-app: kube-dns
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
    - to:
        - podSelector:
            matchLabels:
              app: gate
      ports:
        - protocol: TCP
          port: 8080
    - to:
        - podSelector:
            matchLabels:
              app: store
      ports:
        - protocol: TCP
          port: 9898

```

Apply it:

```sh
kubectl apply -f bay-policies.yaml
```

The policy `store-ingress` has two peers. The first is `crane` in `bay`. The second combines a namespace selector and a pod selector in one peer, so it allows `auditor` in `quay` only. Two separate peers would allow every Pod in `quay`.

