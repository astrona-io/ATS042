# Question

Solve this question on: `terminal`

This is the section capstone: one integrated task without step-by-step guidance.

The namespace `dock` runs the Deployments `loader`, `builder` and `runner`. Harden the namespace so that the three Deployments run under the strictest Pod Security standard. Do not delete a Deployment, a service account or the namespace.

1. `loader` must have no `hostPath` volume.

2. `builder` must not be privileged and must not use the host process, network or IPC namespace.

3. The namespace `dock` must enforce the `restricted` Pod Security standard, and `loader`, `builder` and `runner` must each end with one updated, ready replica. Every container must run as a non-root user with all capabilities dropped, no privilege escalation and the runtime default seccomp profile.

4. Create a RuntimeClass named `isolated` with the handler `kata`, a node selector `isolation: strong` and a fixed pod overhead of `128Mi` of memory. Do not assign it to the three Deployments.

`kubectl` points at the cluster as the cluster administrator.
