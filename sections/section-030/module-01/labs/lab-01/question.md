# Question

Solve this question on: `terminal`

One worker node of this cluster is a restricted node. It carries the label `tier=restricted` and the taint `tier=restricted:NoSchedule`. Do not remove, change or move the label or the taint, and do not delete any object that exists at the start.

1. The Deployment `vault` in `starfleet` must run its pod on the restricted node. Today the pod is Pending. Keep the existing `nodeSelector`. No other Deployment may be changed to run on the restricted node.

2. The service account `intern` in `starfleet` can patch and update nodes, which lets it change labels that placement depends on. Remove those two rights and keep its right to `get` and `list` nodes.

3. In the namespace `outpost`, a pod must not be created with `spec.nodeName` set, because that skips the scheduler. Add a ValidatingAdmissionPolicy and binding that reject such a pod in `outpost`. A pod without `nodeName` must still be accepted.

`kubectl` points at the cluster as the cluster administrator.
