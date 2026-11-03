---
draft: true
exam_objectives:
  - Kubelet
---
# Kubelet And Node Access

Every node runs a kubelet. It talks to the API server as the node, asks the container runtime to run pods, mounts volumes and serves requests for logs, exec and metrics on port 10250. This module explains how callers are authenticated and authorized on that port, how the node proves its identity to the cluster, and what a user can reach through the kubelet that the normal API rules would not suggest.

Keep one sentence in mind: the API server is not the only door to a node.

## Learning objectives

After this module you can:

- Describe what the kubelet does and which ports it serves.
- Read the kubelet configuration fields for authentication, authorization and the read-only port.
- Explain how Webhook authorization maps kubelet paths to node subresources.
- Explain why nodes/proxy and pods/exec are powerful rights and scope them.
- Explain the Node authorizer, NodeRestriction and node client certificates.
- Describe certificate signing requests, who may approve them and why approval must be limited.
- Explain why host mounts of kubelet data and host access defeat pod isolation.

## What the parts cover

1. **Protecting The Node Agent**: explains what the kubelet does, the ports it serves and the configuration fields that matter for security.
2. **Kubelet API Authentication And Authorization**: explains how the kubelet authenticates and authorizes callers, and which RBAC rights reach it.
3. **Node Identity, Certificates And Host Access**: explains node identity, the Node authorizer, certificate signing and the limits of host-level protection.

## Before you start

You need Kubernetes basics: namespaces, Deployments, Services, pods and the commands `kubectl get`, `kubectl apply` and `kubectl describe`. The playground is a kind cluster running Kubernetes 1.35. `kubectl` already points at it as the cluster administrator.

The playground has the Starfleet workloads and three service accounts in `starfleet`. The account `monitor` holds `nodes/proxy`. The account `debugger` can exec into pods in every namespace. The account `intern` can approve certificate signing requests.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
