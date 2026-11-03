# Question

Solve this question on: `terminal`

This is the section capstone: one integrated task without step-by-step guidance.

The namespace `lane` exposes its Services too widely. Fix it. Do not delete the Services or Deployments `cargo` and `beacon`, or the service account `lane-ops`.

1. Every Service in `lane` must be of type `ClusterIP`, must not set `externalIPs` and must not hold a node port.

2. `cargo` and `beacon` must each keep a ready endpoint.

3. The service account `lane-ops` must be able to get, list, watch, create, update, patch and delete Services only in the namespace `lane`, and to get, list and watch EndpointSlices there. It must not be able to create, update, patch or delete Endpoints or EndpointSlices anywhere, and it must not manage Services in any other namespace.

4. The API server must reject a new Service in `lane` that is of type `NodePort` or `LoadBalancer`, or that sets `externalIPs`. A ClusterIP Service must still be accepted.

`kubectl` points at the cluster as the cluster administrator.
