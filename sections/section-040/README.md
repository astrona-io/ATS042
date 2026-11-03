---
draft: true
exam_objectives:
  - Kubelet
---
# Kubelet

The kubelet is the agent on every node. It starts the pods that are assigned to its node, reports their state and serves its own API. That API and the identity of the node are separate security paths from the Kubernetes API server, and each needs its own protection.

## Learning outcomes

- Describe what the kubelet does and which ports it serves.
- Read the kubelet configuration fields for authentication, authorization and the read-only port.
- Explain how Webhook authorization maps kubelet paths to node subresources.
- Explain why nodes/proxy and pods/exec are powerful rights and scope them.
- Explain the Node authorizer, NodeRestriction and node client certificates.
- Describe certificate signing requests, who may approve them and why approval must be limited.
- Explain why host mounts of kubelet data and host access defeat pod isolation.

## What is in this section

The section has one module, Kubelet And Node Access. It has 3 reading parts, a summary and a playground: a single-node cluster with service accounts that hold nodes/proxy, cluster-wide exec and certificate approval rights. A graded lab follows the reading part it practises. A capstone lab closes the section with a new scenario, and a knowledge check of ten questions follows the capstone.
