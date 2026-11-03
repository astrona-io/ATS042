# Question

Solve this question on: `terminal`

The Deployment `relay` in the namespace `hangar` is over-privileged. Fix the following. Do not delete the Deployment `relay` or the service account `relay`.

1. The pod template of `relay` must not run a privileged container, must not use a host namespace and must not mount a host path. It must drop all capabilities, add none, forbid privilege escalation, run as a non-root user and use the `RuntimeDefault` seccomp profile. The Deployment must have one ready replica.

2. `relay` does not call the Kubernetes API. Neither the service account `relay` nor the pod template may mount an API token, and the running pod must not have one.

3. The service account `relay` must keep read access to ConfigMaps in `hangar`. It must not read or list Secrets, and it must not exec into pods or add ephemeral containers.

4. The namespace `hangar` must enforce the `restricted` Pod Security Standard, so that a new privileged pod is rejected.

`kubectl` points at the cluster as the cluster administrator.
