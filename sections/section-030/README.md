---
draft: true
exam_objectives:
  - Scheduler
---
# Scheduler

The kube-scheduler decides which node runs each new pod. It does not start containers, but its decisions control where code runs, which workloads share a node and whether pods run at all. This section explains how placement works, which settings turn a placement rule into a security rule, and how scheduling fails.

## Learning outcomes

- Describe the scheduling cycle: filtering, scoring and binding.
- Use nodeSelector, affinity, taints and tolerations, and explain what each one guarantees.
- Explain why labels used for security need controlled ownership, and what NodeRestriction does.
- Explain how spec.nodeName and the pods/binding subresource bypass the scheduler, and block them.
- Use PriorityClass, preemption and ResourceQuota scopes to protect availability.
- Diagnose a Pending pod from its FailedScheduling events.
- Read the scheduler flags and configuration that affect security.

## What is in this section

The section has one module, Scheduler Integrity And Availability. It has 3 reading parts, a summary and a playground: a three-node cluster with one restricted node, a Pending workload that needs it and a service account that can change node labels. A graded lab follows the reading part it practises. A capstone lab closes the section with a new scenario, and a knowledge check of ten questions follows the capstone.
