---
draft: true
exam_objectives:
  - Pod
---
# Pod Execution And Credential Boundaries

A pod is the unit that runs application code, and it carries both the execution settings of its containers and a credential for the Kubernetes API. Both decide what a compromised process can do next.

## Learning outcomes

- List what containers in one pod share and what stays separate.
- Name the pod settings that remove container isolation.
- Apply Pod Security Standards with namespace labels and explain what the labels do not cover.
- Describe how a service account token is created, bound and refreshed.
- Remove the API token from a workload that does not need it.
- Explain why Secret read rights and Pod creation rights are credential rights.
- Explain the permissions behind exec, attach, port forwarding and ephemeral containers.
- List what recovery must replace after a pod is compromised.

## What is in this section

The section has one module, Pod Execution And Credential Boundaries. It has 3 reading parts, a summary and a playground: a cluster to test Pod Security Admission labels, inspect service account tokens and review a role that allows exec and Secret reads. A graded lab follows the reading part it practises. A capstone lab closes the section with a new scenario, and a knowledge check of ten questions follows the capstone.
