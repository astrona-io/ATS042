# Question

Solve this question on: `terminal`

Three service accounts in `starfleet` hold rights that reach the kubelet. Reduce each one. Do not delete any service account.

1. The account `monitor` collects node metrics. Today it holds `nodes/proxy`, which forwards any request to the kubelet. It must be able to `get` and `list` `nodes`, and to `get` `nodes/metrics` and `nodes/stats`. It must not hold `nodes/proxy` with any verb.

2. The account `debugger` may exec into pods and read logs only in the namespace `outpost`. It must no longer exec, attach or port-forward in any other namespace.

3. The account `intern` must not approve certificate signing requests. Remove its approval rights. It may keep read access to the requests.

`kubectl` points at the cluster as the cluster administrator.
