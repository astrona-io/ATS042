# Overview: Etcd And Stored Cluster Data (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Change things, break them, run `astrona destroy`, and start over.

## What is in the cluster

- A kind cluster running Kubernetes 1.35 with one node and a kubeadm-style etcd static Pod in `kube-system`.
- The Starfleet workloads: `scout`, `probe` and `shuttle` in `starfleet`, and `drifter` in `outpost`.
- The Secret `warp-key`, the service account `archivist` and the ClusterRole `secret-reader` with a ClusterRoleBinding.

## Helpers

```sh
can_archivist() {
  kubectl auth can-i "$@" --as=system:serviceaccount:starfleet:archivist
}
```

Use `can_archivist VERB RESOURCE [-n NAMESPACE | -A]`, for example `can_archivist list secrets -A`.

## Practice tasks

- Print the etcd command line with `kubectl -n kube-system get pod -l component=etcd -o jsonpath='{.items[0].spec.containers[0].command}'` and find `--client-cert-auth` and `--data-dir`.
- List the host paths of the etcd Pod and name the two directories that open the datastore.
- Validate a Pod that mounts `/etc/kubernetes/pki/etcd` with `kubectl apply --dry-run=server` and note that the API accepts it.
- Run `can_archivist list secrets -A` and `can_archivist get secrets -n kube-system`, then replace `secret-reader` with a rule that names `warp-key`.
- Make `warp-key` immutable with `kubectl -n starfleet patch secret warp-key --type=merge -p '{"immutable":true}'` and try to change its data.
