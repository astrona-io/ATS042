# Question

Solve this question on: `terminal`

This is the section capstone: one integrated task without step-by-step guidance.

The namespace `deck` runs the Deployment `hold`. Two certificate requests wait for a decision: `pilot` and `pilot-root`. The automation account `loader` in `deck` has a legacy token Secret and a binding to `cluster-admin`. The ConfigMap `ci-kubeconfig` holds the kubeconfig of the build job. Do not change the Deployment.

1. Approve the request that asks for a normal flight crew identity and deny the one that asks for full cluster rights. The approved request must have a signed certificate.

2. The holders of the approved certificate must read Deployments in `deck` (`get`, `list` and `watch` on `deployments` in the group `apps`). Grant this through the group in the certificate with a Role and a RoleBinding. The user name alone, without the group, must not receive it. Nothing else is allowed.

3. `loader` must not keep a legacy token Secret or any cluster-wide binding.

4. `loader` may only `get` and `patch` Deployments in `deck`. It must not create or delete them, read Secrets or reach other namespaces.

5. Replace the ConfigMap `ci-kubeconfig` with a Secret of the same name and the key `config`. The new file must verify the server with the cluster certificate authority from `kube-root-ca.crt`, must not skip verification, must not embed a token or run a program, and must read the token from a `tokenFile`.

`kubectl` points at the cluster as the cluster administrator.
