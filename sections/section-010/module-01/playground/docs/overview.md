# Overview: API Server Security Boundaries (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Change things, break them, run `astrona destroy`, and start over.

## What is in the cluster

- A kind cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator. Use `--as` and `--as-group` to test other identities.
- The Starfleet workloads: `scout`, `probe` and `shuttle` in `starfleet`, and `drifter` in `outpost`.
- The service account `ci-deployer` in `starfleet`, bound to `cluster-admin` by the ClusterRoleBinding `ci-deployer-admin`.
- The ClusterRoleBinding `public-reader`, which gives the `view` ClusterRole to the group `system:unauthenticated`.

## Helpers

```sh
can_sa() {
  kubectl auth can-i "$2" "$3" -n "${4:-starfleet}" --as="system:serviceaccount:starfleet:$1"
}
can_anonymous() {
  kubectl auth can-i "$1" "$2" -n "${3:-starfleet}" --as=system:anonymous --as-group=system:unauthenticated
}
```

Use them like this: `can_sa ci-deployer delete deployments` and `can_anonymous list pods`.

## Practice tasks

- Run `can_anonymous list pods` and find the binding that causes the answer. Remove it and ask again.
- Find the API server flags with `kubectl -n kube-system get pod -l component=kube-apiserver -o yaml` and read `--authorization-mode`, `--anonymous-auth` and `--enable-admission-plugins`.
- Give `ci-deployer` only the verbs it needs on Deployments in `starfleet`, then check each verb with `can_sa`.
- Write a ValidatingAdmissionPolicy that rejects privileged pods in `outpost`, bind it, and try to create a privileged pod with a server-side dry run.
- Set `automountServiceAccountToken: false` on the `probe` service account, restart the Deployment and look at the pod volumes.
