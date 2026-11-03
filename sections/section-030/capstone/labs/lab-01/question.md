# Question

Solve this question on: `terminal`

This is the section capstone: one integrated task without step-by-step guidance.

The namespace `armada` has scheduling problems and placement bypasses. Fix them. Do not delete any object that exists at the start, and do not change the PriorityClass `urgent`.

1. The Deployment `cargo` must run its two replicas.

2. The two replicas of the Deployment `relay` must always run on different nodes. If no different node is free, the second replica must stay Pending instead of sharing a node.

3. No new pod in `armada` may use the priority class `urgent`. Pods without a priority class must still be accepted.

4. The service account `armada-ops` must not be able to bind pods to nodes or to change nodes. It may keep read access to pods.

`kubectl` points at the cluster as the cluster administrator.
