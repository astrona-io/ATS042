# Solution

Solve this lab on `terminal`. After each step, run `astrona submit` to see which checks pass. The `--keep` flag keeps the lab running after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-090/module-01/labs/lab-01
```

The reference solution adds three policies in `starfleet`.

## Step 1: Allow only shuttle to probe

Save this as `probe-ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: probe-ingress
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: probe
  policyTypes: ["Ingress"]
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: shuttle
      ports:
        - protocol: TCP
          port: 8080
```

Apply it and run `astrona submit`:

```sh
kubectl apply -f probe-ingress.yaml
```

The port is the container port 8080, not the Service port 80.

## Step 2: Limit scout to its own namespace

Save this as `scout-ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: scout-ingress
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: scout
  policyTypes: ["Ingress"]
  ingress:
    - from:
        - podSelector: {}
      ports:
        - protocol: TCP
          port: 9898
```

Apply it and run `astrona submit`:

```sh
kubectl apply -f scout-ingress.yaml
```

The empty `podSelector` in `from` selects every Pod in the namespace of the policy.

## Step 3: Restrict the egress of shuttle

Save this as `shuttle-egress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: shuttle-egress
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: shuttle
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
              app: probe
      ports:
        - protocol: TCP
          port: 8080
    - to:
        - podSelector:
            matchLabels:
              app: scout
      ports:
        - protocol: TCP
          port: 9898

```

Apply it and run `astrona submit`:

```sh
kubectl apply -f shuttle-egress.yaml
```

Without the DNS rule, `shuttle` could no longer resolve the Service names.

