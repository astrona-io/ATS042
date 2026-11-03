# Question

Solve this question on: `terminal`

The Service `gateway` in `starfleet` exposes the Deployment `probe` more widely than needed, and the cluster allows risky changes. Fix the following. Do not delete the Service `gateway`, the Deployment `probe` or the service account `intern`.

1. The Service `gateway` must be of type `ClusterIP`, must not set `externalIPs` and must not hold a node port. It must keep selecting the pods with the label `app: probe` on port 80 and must have a ready endpoint.

2. In the namespace `starfleet`, the API server must reject a new Service that sets `externalIPs`. Ordinary ClusterIP Services must still be accepted.

3. The service account `intern` must no longer create, update, patch or delete Services, Endpoints or EndpointSlices. It must still be able to `get` and `list` Services in `starfleet`.

4. The ConfigMap `kube-proxy` in `kube-system` sets `metricsBindAddress` on every address. Set it to the loopback address `127.0.0.1:10249`. Leave the other settings and keys unchanged.

`kubectl` points at the cluster as the cluster administrator.
