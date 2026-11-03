# Question

Solve this question on: `terminal`

The cluster in `starfleet` and `outpost` has three access problems found in a security review. Fix them with Kubernetes objects. Do not delete any workload or namespace.

1. The group `system:unauthenticated` can read pods and other objects in every namespace. Remove that access without changing the built-in `view` ClusterRole.

2. The service account `ci-deployer` in `starfleet` is bound to `cluster-admin`. Remove that grant and keep the service account. It must be able to read (`get`, `list`, `watch`), create, `update` and `patch` Deployments in `starfleet`, and nothing else. It must not delete Deployments, read Secrets, or act in another namespace.

3. The namespace `outpost` must reject privileged pods at admission. Use a `ValidatingAdmissionPolicy` and a `ValidatingAdmissionPolicyBinding`. Ordinary pods in `outpost` must still be accepted.

4. The Deployment `probe` in `starfleet` never calls the Kubernetes API, but its pods mount a service account token. Stop the token from being mounted into new `probe` pods and make sure the running pod is replaced.

`kubectl` points at the cluster as the cluster administrator. Check any identity with `--as` and `--as-group`.
