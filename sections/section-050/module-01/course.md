---
draft: true
exam_objectives:
  - Container Runtime
---
# Container Runtime Protection

The kubelet asks a container runtime to pull images and start containers. The runtime talks to the kernel, creates namespaces and control groups and runs the process. This module explains the interfaces between those layers, the pod settings that remove isolation, how Pod Security Admission rejects them and how a RuntimeClass selects a stronger runtime.

Keep one sentence in mind: a container is only as isolated as its pod specification allows.

## Learning objectives

After this module you can:

- Describe the layers between a pod and a running process: kubelet, CRI, high-level runtime, OCI runtime and kernel.
- Explain why the runtime socket gives host authority that Kubernetes RBAC does not control.
- Read the runtime and container identifiers that the Kubernetes API shows.
- List the pod settings that remove isolation: privileged, hostPath, host namespaces and added capabilities.
- Apply the baseline and restricted Pod Security Standards with namespace labels.
- Explain what a RuntimeClass contains and what it does not install.
- Choose between ordinary containers and a stronger isolation boundary.

## What the parts cover

1. **Runtime Interfaces And Host Authority**: explains the layers that start a container, the CRI socket and what the Kubernetes API shows about the runtime.
2. **Protecting Runtime Access And Execution Privileges**: explains the pod settings that remove isolation and how Pod Security Admission rejects them.
3. **Runtime Classes And Stronger Isolation**: explains RuntimeClass, sandboxed runtimes and the hardening that applies to every container.

## Before you start

You need Kubernetes basics: namespaces, Deployments, Services, pods and the commands `kubectl get`, `kubectl apply` and `kubectl describe`. The playground is a kind cluster running Kubernetes 1.35. `kubectl` already points at it as the cluster administrator.

The playground has the Starfleet workloads and two namespaces, `starfleet` and `outpost`, with no Pod Security labels. You can read which runtime the node uses, validate risky pod specifications and then label a namespace to see them rejected.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
