---
draft: true
exam_objectives:
  - Container Runtime
---
# Container Runtime

The container runtime turns a pod specification into running processes on a node. It acts with the authority of the node, so the settings that give a pod access to the runtime or to the host decide how far a compromised container can reach.

## Learning outcomes

- Describe the layers between a pod and a running process: kubelet, CRI, high-level runtime, OCI runtime and kernel.
- Explain why the runtime socket gives host authority that Kubernetes RBAC does not control.
- Read the runtime and container identifiers that the Kubernetes API shows.
- List the pod settings that remove isolation: privileged, hostPath, host namespaces and added capabilities.
- Apply the baseline and restricted Pod Security Standards with namespace labels.
- Explain what a RuntimeClass contains and what it does not install.
- Choose between ordinary containers and a stronger isolation boundary.

## What is in this section

The section has one module, Container Runtime Protection. It has 3 reading parts, a summary and a playground: a cluster to inspect the runtime, try privileged pod specifications and apply Pod Security labels. A graded lab follows the reading part it practises. A capstone lab closes the section with a new scenario, and a knowledge check of ten questions follows the capstone.
