---
draft: true
exam_objectives:
  - Scheduler
---
# Scheduler Integrity And Availability

A pod that has no node is unscheduled. The kube-scheduler watches for those pods, picks a node for each one and records the choice by creating a binding through the API server. The kubelet on that node then starts the pod. This module follows that decision, shows where an attacker or a mistake can change it, and teaches the controls that keep placement trustworthy and available.

Keep one sentence in mind: a placement rule is a security rule only when the people who can change the node labels, the taints and the pod fields are controlled.

## Learning objectives

After this module you can:

- Describe the scheduling cycle: filtering, scoring and binding.
- Use nodeSelector, affinity, taints and tolerations, and explain what each one guarantees.
- Explain why labels used for security need controlled ownership, and what NodeRestriction does.
- Explain how spec.nodeName and the pods/binding subresource bypass the scheduler, and block them.
- Use PriorityClass, preemption and ResourceQuota scopes to protect availability.
- Diagnose a Pending pod from its FailedScheduling events.
- Read the scheduler flags and configuration that affect security.

## What the parts cover

1. **Protecting Placement Decisions**: explains the scheduling cycle, the scheduler identity and the flags and configuration that affect security.
2. **Placement Rules, Taints And Labels**: explains selectors, affinity, taints, tolerations and who controls node labels.
3. **Binding, Priority And Availability**: explains how placement is bypassed, how priorities and quotas protect availability and how to diagnose Pending pods.

## Before you start

You need Kubernetes basics: namespaces, Deployments, Services, pods and the commands `kubectl get`, `kubectl apply` and `kubectl describe`. The playground is a kind cluster running Kubernetes 1.35. `kubectl` already points at it as the cluster administrator.

The playground has one control plane node and two worker nodes. One worker has the label `tier=restricted` and the taint `tier=restricted:NoSchedule`. The Deployment `vault` in `starfleet` selects that label but has no toleration, so its pod stays Pending. The service account `intern` can patch nodes.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
