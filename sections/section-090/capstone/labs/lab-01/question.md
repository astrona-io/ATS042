# Question

Solve this question on: `terminal`

This is the section capstone: one integrated task without step-by-step guidance.

The namespace `bay` holds `gate` (container port 8080), `store` (container port 9898) and the client `crane`. The namespace `quay` holds the clients `auditor` and `stranger` and the service `lighthouse`. The Services have the same names as the workloads. Everything is open. Add NetworkPolicy objects so that the following holds. Do not change the Deployments.

1. Every Pod in `bay` is isolated for ingress by default, and a NetworkPolicy in `bay` selects every Pod and lists `Ingress` in its policy types.

2. `gate` accepts connections from `crane` only. `auditor` and `stranger` must not reach it.

3. `store` accepts connections from `crane` and from `auditor` in the namespace `quay`. `stranger` in `quay` must not reach it, and no other Pod of `quay` may reach it.

4. `crane` may send traffic only to `gate`, to `store` and to DNS. It must not reach `lighthouse`, and it must still reach `gate` and `store` by their Service names. A NetworkPolicy in `bay` must restrict the egress of `crane`.

5. Traffic in `quay` is unchanged: `auditor` and `stranger` must still reach `lighthouse`.

Test with `kubectl exec` and `curl` from the client Pods. `kubectl` points at the cluster as the cluster administrator.
