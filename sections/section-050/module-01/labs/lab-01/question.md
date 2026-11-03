# Question

Solve this question on: `terminal`

The Deployment `courier` in the namespace `outpost` was set up with host access. Reduce its privileges and protect the namespace. Do not delete the Deployment or its namespace.

1. The container in `courier` must not run privileged, must not allow privilege escalation, must drop all capabilities and must not add any capability.

2. The pods of `courier` must have no `hostPath` volume and must not use the host process, network or IPC namespace. The Deployment must finish a rollout with one ready replica.

3. The namespace `outpost` must enforce the `baseline` Pod Security standard or a stricter one, so that a privileged pod is rejected there.

4. Create a RuntimeClass named `sandboxed` with the handler `runsc` and a fixed pod overhead of `100m` of CPU and `64Mi` of memory.

`kubectl` points at the cluster as the cluster administrator.
