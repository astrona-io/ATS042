---
draft: true
exam_objectives:
  - Pod
---
# Pod Execution And Credential Boundaries

A pod runs containers that share a network namespace, can share volumes and carry one identity toward the Kubernetes API. This module explains which pod settings remove container isolation, how Pod Security Admission blocks them, how the service account token reaches the container and how to remove it, and what exec and debug rights allow. It ends with what recovery must replace after a compromise.

Keep one sentence in mind: a pod is exactly as trusted as its specification, its token and the people who can enter it.

## Learning objectives

After this module you can:

- List what containers in one pod share and what stays separate.
- Name the pod settings that remove container isolation.
- Apply Pod Security Standards with namespace labels and explain what the labels do not cover.
- Describe how a service account token is created, bound and refreshed.
- Remove the API token from a workload that does not need it.
- Explain why Secret read rights and Pod creation rights are credential rights.
- Explain the permissions behind exec, attach, port forwarding and ephemeral containers.
- List what recovery must replace after a pod is compromised.

## What the parts cover

1. **Pod-Level Privileges And Application Access**: explains what containers in a pod share, the settings that remove isolation and Pod Security Admission.
2. **Service Account Tokens And API Credentials**: explains how the service account token reaches the container, how to remove it and how to scope its rights.
3. **Interactive Access And Recovery**: explains exec, attach and ephemeral container permissions, and what recovery must replace.

## Before you start

You need Kubernetes basics: namespaces, Deployments, Services, pods and the commands `kubectl get`, `kubectl apply` and `kubectl describe`. The playground is a kind cluster running Kubernetes 1.35. `kubectl` already points at it as the cluster administrator.

The playground has the Starfleet workloads and a service account `crew` that can read Secrets, exec into pods and add ephemeral containers in `starfleet`. You can label namespaces, validate pods that break a standard and check what a token holds.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
