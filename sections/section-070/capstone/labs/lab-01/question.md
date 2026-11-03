# Question

Solve this question on: `terminal`

This is the section capstone: one integrated task without step-by-step guidance.

The namespace `galley` runs two workloads, `pantry` and `oven`, and one operator account `chef`. Fix it. Do not delete the Deployments or the service accounts.

1. Both Deployments must run without privileged containers, host namespaces and host paths, drop all capabilities, forbid privilege escalation, run as non-root and use the `RuntimeDefault` seccomp profile. Each must keep one ready replica.

2. Neither workload calls the Kubernetes API. The service accounts `pantry`, `oven` and `chef` must not mount tokens by default, the pod templates must say so, and running pods must have no API token.

3. The service account `chef` must be able to get, list and watch pods and read pod logs in `galley`. It must not read or list Secrets, exec into pods, add ephemeral containers, or create or delete pods.

4. The namespace must reject new pods that break the `restricted` standard.

`kubectl` points at the cluster as the cluster administrator.
