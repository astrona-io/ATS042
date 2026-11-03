# Overview: Container Runtime Protection (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Change things, break them, run `astrona destroy`, and start over.

## What is in the cluster

- A kind cluster with one node, running Kubernetes 1.35 and containerd.
- The Starfleet workloads: `scout`, `probe` and `shuttle` in `starfleet`, and `drifter` in `outpost`.
- No Pod Security labels and no RuntimeClass objects.

## Helpers

```sh
node_name() {
  kubectl get nodes -o jsonpath='{.items[0].metadata.name}'
}
try_pod() {
  kubectl apply --dry-run=server -f "$1"
}
```

Use `node_name` to print the node name, and `try_pod FILE` to ask the API server to validate a pod specification without saving it.

## Practice tasks

- Read the runtime and its version with `kubectl get nodes -o wide` and with a `jsonpath` on `status.nodeInfo.containerRuntimeVersion`.
- Read the container identifier of `scout` from `status.containerStatuses` and note the runtime prefix.
- Describe the `scout` pod and find the events for the image pull, the creation and the start of the container.
- Save a pod that sets `privileged: true` and mounts `/run/containerd` with a `hostPath` volume. Validate it with `try_pod`. Then label the namespace with `pod-security.kubernetes.io/enforce=baseline` and validate it again.
- Create a RuntimeClass named `sandboxed` with the handler `runsc` and read it back with `kubectl get runtimeclass sandboxed -o yaml`.
