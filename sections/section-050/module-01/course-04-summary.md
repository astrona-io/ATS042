---
draft: true
exam_objectives:
  - Container Runtime
---
# Summary

The kubelet does not start containers itself. It calls the Container Runtime Interface on a local socket. A high-level runtime such as containerd or CRI-O implements that interface, stores images and calls a low-level OCI runtime such as runc, which creates the namespaces and control groups and starts the process. The CRI socket is owned by root, and a caller that can open it can create and control containers without any Kubernetes authorization.

Several pod settings remove isolation. A privileged container, a hostPath mount, the host process, network and IPC namespaces, added capabilities such as SYS_ADMIN and a mounted runtime socket each give the process more of the host. A non-root user does not repair these settings. Safer workloads run as a non-root user, drop all capabilities, forbid privilege escalation, use the runtime default seccomp profile and avoid host mounts.

Pod Security Admission enforces the privileged, baseline and restricted standards through namespace labels. The modes enforce, audit and warn decide whether a violation is rejected, recorded or only reported. Enforcement applies when pods are created or updated, so running pods are not removed when a label is added, and a controller whose pods are rejected shows the error on its ReplicaSet.

A RuntimeClass names a runtime handler, optional pod overhead and optional scheduling rules. It does not install the handler. Sandboxed runtimes such as a user-space kernel or a lightweight virtual machine add a boundary at a cost in compatibility and performance, and they do not replace network rules or narrow credentials.

Key facts:

- Calls through the runtime socket bypass Kubernetes RBAC and admission.
- A privileged container or a runtime-socket mount is host access even for a non-root user.
- The label pod-security.kubernetes.io/enforce rejects pods that violate the chosen standard.
- A RuntimeClass with a missing handler leaves its pods in ContainerCreating.

<!-- astrona:playground:destroy -->
