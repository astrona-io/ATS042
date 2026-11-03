# Question

Solve this question on: `terminal`

This is the section capstone: one integrated task without step-by-step guidance.

The namespace `deck` and the cluster have several paths to the kubelet and to node data. Close them. Do not delete any service account, the ClusterRole `csr-approver`, or the Deployment `inspector`.

1. The service account `auditor` in `deck` may `get` and `list` `nodes`, `nodes/metrics` and `nodes/stats`, and nothing else on nodes.

2. The service account `ops` in `deck` may read pods and pod logs and exec into pods only inside the namespace `deck`. It may not attach or port-forward anywhere.

3. Only members of the group `pki-admins` may approve certificate signing requests. No other authenticated user may.

4. The Deployment `inspector` must run without any hostPath volume and must stay ready.

`kubectl` points at the cluster as the cluster administrator.
