# Question

Solve this question on: `terminal`

The namespaces `starfleet` and `outpost` are fully open. The clients are `shuttle` and `visitor` in `starfleet`, and `drifter` in `outpost`. The Service names are `probe` and `scout` in `starfleet` and `beacon` in `outpost`. Add NetworkPolicy objects so that the following holds. Do not delete or change the Deployments.

1. `probe` (container port 8080) accepts connections from `shuttle` only. `visitor` and `drifter` must not reach it.

2. `scout` (container port 9898) accepts connections from the Pods of the namespace `starfleet` only. `drifter` must not reach it, and `shuttle` and `visitor` must still reach it.

3. `shuttle` may send traffic only to `probe` on port 8080, to `scout` on port 9898 and to DNS. `shuttle` must not reach `beacon` in `outpost`, and it must still reach `probe` and `scout` by their Service names. At least one NetworkPolicy in `starfleet` must restrict egress.

4. Do not break other traffic: `drifter` must still reach `beacon`.

Test with `kubectl exec` and `curl` from the client Pods, for example `kubectl -n starfleet exec deploy/shuttle -- curl -sS --max-time 3 http://probe.starfleet.svc/get`. `kubectl` points at the cluster as the cluster administrator.
