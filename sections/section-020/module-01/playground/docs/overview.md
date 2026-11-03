# Overview: Controller Manager Authority (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Change things, break them, run `astrona destroy`, and start over.

## What is in the cluster

- A kind cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.
- The Deployment `fleet-controller` in `starfleet`, running as the service account `fleet-controller`.
- The ClusterRole and ClusterRoleBinding `fleet-controller`, which allow every verb on every resource.
- The service account `intern` and the ClusterRoleBinding `intern-role-manager`, which allows managing roles with `escalate` and `bind`.
- The ConfigMaps `fleet-state` and `fleet-notes` and the Secret `fleet-key` in `starfleet`.

## Helpers

```sh
can_sa() {
  kubectl auth can-i "$2" "$3" -n "${4:-starfleet}" --as="system:serviceaccount:starfleet:$1"
}
```

Use it like this: `can_sa fleet-controller delete secrets` and `can_sa intern escalate clusterroles`.

## Practice tasks

- List the controller manager flags with `kubectl -n kube-system get pod -l component=kube-controller-manager -o yaml` and find `--use-service-account-credentials`.
- List the `system:controller:` ClusterRoles with `kubectl get clusterroles | grep system:controller` and read one with `kubectl get clusterrole system:controller:replicaset-controller -o yaml`.
- Delete one `scout`-style pod owned by a ReplicaSet and watch it come back with `kubectl get pods -w`. Then read its `ownerReferences`.
- Replace the wildcard role of `fleet-controller` with a Role that can only read ConfigMaps and update the ConfigMap `fleet-state`.
- Remove the `escalate` and `bind` verbs from the role of `intern` and prove with `can_sa` that the account can no longer grant itself more rights.
