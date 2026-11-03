# Question

Solve this question on: `terminal`

A Deployment `fleet-controller` in `starfleet` stands in for a custom controller. Its service account is `fleet-controller`. A review found these problems. Do not delete the Deployment, the service accounts or the ConfigMaps.

1. The service account `fleet-controller` is bound to a ClusterRole that allows every verb on every resource in every namespace. Remove the cluster-wide grant. Use a namespaced Role instead. The controller must be able to `get`, `list` and `watch` ConfigMaps in `starfleet`, and to `update` and `patch` only the ConfigMap named `fleet-state`. It must not read Secrets, change other ConfigMaps, delete anything, or act in another namespace.

2. The service account `intern` in `starfleet` can create roles and bindings and holds the verbs `escalate` and `bind`. Remove those two verbs and keep its right to `get` and `list` pods.

3. The ConfigMap `fleet-state` must be deleted automatically when the Deployment `fleet-controller` is deleted. Make the Deployment its owner.

`kubectl` points at the cluster as the cluster administrator.
