# Overview: Storage Access And Data Security (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Change things, break them, run `astrona destroy`, and start over.

## What is in the cluster

- A kind cluster running Kubernetes 1.35 with one node and the default storage class `standard`.
- The Starfleet workloads: `scout`, `probe` and `shuttle` in `starfleet`, and `drifter` in `outpost`.
- The service account `runner` with a Role that reads pods in `starfleet`.
- No claims at the start.

## Helpers

```sh
can_runner() {
  kubectl auth can-i "$@" --as=system:serviceaccount:starfleet:runner
}
```

Use `can_runner VERB RESOURCE -n NAMESPACE`, for example `can_runner create pods -n starfleet`.

## Practice tasks

- List the storage classes with `kubectl get storageclass` and note the provisioner, reclaim policy and binding mode.
- Create a claim `records` in `starfleet`, check that it is `Pending`, and start a pod that mounts it.
- Start a second pod that mounts the same claim and read the file that the first pod wrote.
- Mount the claim read-only in a third pod and show that writes fail and reads work.
- Change the reclaim policy of the volume to `Retain`, delete the pod and the claim and read the status of the volume.
- Create a namespace labeled with the `baseline` profile and check that a hostPath pod is rejected with a dry run.
