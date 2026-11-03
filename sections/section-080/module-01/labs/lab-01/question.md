# Question

Solve this question on: `terminal`

The Deployment `snapshotter` in the namespace `archive` exposes stored cluster data. Fix the following. Do not delete the Deployment `snapshotter`, the service account `snapshotter` or the Secret `backup-key`.

1. The pod template of `snapshotter` must not mount any host path. The Deployment must have one ready replica.

2. The service account `snapshotter` must be able to `get` the Secret `backup-key` in `archive` and nothing else. It must not read or list other Secrets in `archive` or any other namespace, and it must not get a Secret named `backup-key` in another namespace.

3. Members of the groups `system:authenticated` and `system:unauthenticated` must not get, list or watch Secrets in `archive`.

4. The password in the ConfigMap `snapshot-settings` must move to a Secret named `snapshot-credentials` under the key `password`, with the same value. The ConfigMap must keep only the key `schedule`, and the container environment variable `BACKUP_PASSWORD` must read from the Secret.

`kubectl` points at the cluster as the cluster administrator.
