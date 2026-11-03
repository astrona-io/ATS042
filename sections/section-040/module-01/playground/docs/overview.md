# Overview: Kubelet And Node Access (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Change things, break them, run `astrona destroy`, and start over.

## What is in the cluster

- A kind cluster with one node, running Kubernetes 1.35.
- The Starfleet workloads: `scout`, `probe` and `shuttle` in `starfleet`, and `drifter` in `outpost`.
- The service accounts `monitor`, `debugger` and `intern`, with ClusterRoles `node-monitor`, `pod-debugger` and `csr-approver`.

## Helpers

```sh
node_name() {
  kubectl get nodes -o jsonpath='{.items[0].metadata.name}'
}
can_sa() {
  kubectl auth can-i "$2" "$3" ${4:+--subresource="$4"} -n "${5:-starfleet}" --as="system:serviceaccount:starfleet:$1"
}
```

Use `node_name` to print the node name, and `can_sa monitor get nodes proxy` to test a service account. The arguments are the service account, the verb, the resource, an optional subresource and an optional namespace.

## Practice tasks

- Read the kubelet configuration with `kubectl -n kube-system get configmap kubelet-config -o yaml` and find `authentication`, `authorization` and `readOnlyPort`.
- Read the live kubelet configuration through the API server with `kubectl get --raw "/api/v1/nodes/$(node_name)/proxy/configz"`. Then repeat the request as `monitor` with `--as=system:serviceaccount:starfleet:monitor`.
- Test `can_sa debugger create pods exec starfleet` and `can_sa debugger create pods exec outpost`. Replace the ClusterRoleBinding with a RoleBinding in `outpost` only and test again.
- Run `can_sa intern update certificatesigningrequests approval` and remove the approval rights from `intern`.
- List the certificate signing requests with `kubectl get csr` and read the signer name of each one.
