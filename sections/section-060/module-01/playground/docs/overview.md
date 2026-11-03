# Overview: KubeProxy And Service Forwarding (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Change things, break them, run `astrona destroy`, and start over.

## What is in the cluster

- A kind cluster with one node, running Kubernetes 1.35 with kube-proxy in `iptables` mode.
- The Starfleet workloads: `scout`, `probe` and `shuttle` in `starfleet`, and `drifter` in `outpost`.
- The service account `intern` with the ClusterRole `traffic-editor`.

## Helpers

```sh
can_intern() {
  kubectl auth can-i "$1" "$2" -n "${3:-starfleet}" --as=system:serviceaccount:starfleet:intern
}
```

Use `can_intern VERB RESOURCE [NAMESPACE]`, for example `can_intern create endpointslices.discovery.k8s.io`.

## Practice tasks

- List the kube-proxy pods with `kubectl -n kube-system get pods -l k8s-app=kube-proxy -o wide`.
- Compare the Service `scout` with its EndpointSlice and note which address belongs to the pod.
- Read the kube-proxy configuration with `kubectl -n kube-system get configmap kube-proxy -o jsonpath='{.data.config\.conf}'` and find `mode`, `metricsBindAddress` and `healthzBindAddress`.
- Read the ClusterRole `system:node-proxier` and list which resources it can read.
- Test `can_intern create endpointslices.discovery.k8s.io` and `can_intern patch services`, then apply the admission policy from the reading and validate a Service with `externalIPs`.
