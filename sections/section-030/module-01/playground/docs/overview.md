# Overview: Scheduler Integrity And Availability (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Change things, break them, run `astrona destroy`, and start over.

## What is in the cluster

- A kind cluster with one control plane node and two worker nodes, running Kubernetes 1.35.
- The Starfleet workloads `scout`, `probe` and `shuttle` in `starfleet`, and `drifter` in `outpost`.
- One worker labelled `tier=restricted` and tainted `tier=restricted:NoSchedule`.
- The Deployment `vault` in `starfleet`, with `nodeSelector` `tier: restricted` and no toleration.
- The service account `intern`, bound through `node-labeler` to `get`, `list`, `patch` and `update` on nodes.

## Helpers

```sh
node_info() {
  kubectl get nodes -L tier
  kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
}
can_sa() {
  kubectl auth can-i "$2" "$3" --as="system:serviceaccount:starfleet:$1"
}
```

Use `node_info` to see labels and taints, and `can_sa intern patch nodes` to test the service account.

## Practice tasks

- Run `kubectl -n starfleet describe pod -l app=vault` and read the `FailedScheduling` event. Name the taint that blocks the pod.
- Add a toleration for `tier=restricted:NoSchedule` to the Deployment `vault` and watch the pod start on the restricted node.
- Check where `scout` runs with `kubectl -n starfleet get pods -o wide` and confirm that no ordinary pod runs on the restricted node.
- Use `can_sa intern patch nodes`, then remove the node rights of `intern` and test again.
- Create a pod in `outpost` with `spec.nodeName` set to a worker name. Check that it skips the scheduler, then write a ValidatingAdmissionPolicy that rejects it.
