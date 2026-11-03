# Question

Solve this question on: `terminal`

This is the section capstone: one integrated task without step-by-step guidance.

The namespace `vault` holds backup tooling and exposes stored cluster data. Fix it. Do not delete the Deployments `exporter` and `restore`, the service account `backup-ops` or the Secret `archive-key`.

1. `exporter` and `restore` must not mount any host path, and each must have one ready replica.

2. The service account `backup-ops` must be able to `get` the Secret `archive-key` in `vault` and nothing else. It must not read or list other Secrets anywhere, it must not create, update or delete Secrets, and it must not get `archive-key` outside `vault`.

3. Members of the groups `system:authenticated` and `system:unauthenticated` must not get, list or watch Secrets in `vault` or `kube-system`.

4. The access key in the ConfigMap `backup-target` must move to a Secret named `backup-target-credentials` under the key `access-key`, with the same value. The ConfigMap must keep the key `bucket` only, and the environment variable `ACCESS_KEY` of `exporter` must read from the Secret.

5. The Secret `archive-key` must be immutable and keep its data.

`kubectl` points at the cluster as the cluster administrator.
