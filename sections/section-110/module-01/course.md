---
draft: true
exam_objectives:
  - Storage
---
# Storage Access And Data Security

Applications keep records in persistent volumes. This module explains the storage objects and how a claim becomes a volume, which permissions really give access to the data, what read-only mounts, access modes and reclaim policies change, and how host paths, snapshots and backups open other routes. It ends with what deletion does and does not erase.

Keep one sentence in mind: whoever can start a pod in a namespace can read every claim in that namespace.

## Learning objectives

After this module you can:

- Describe how a claim, a volume and a storage class relate and how binding works.
- Explain why permission on a claim object does not control the data.
- Name the rights that give access to mounted data.
- Use read-only mounts and explain what they do not protect.
- Compare access modes and state what they promise.
- Explain the reclaim policies and the risk of each.
- Explain why host path volumes are dangerous and how Pod Security Admission refuses them.
- Explain what snapshots, backups and encryption at rest protect and what deletion leaves behind.

## What the parts cover

1. **Volumes, Claims And Who Reaches The Data**: explains the storage objects, how binding works and which rights reach the stored data.
2. **Mount Options, Access Modes And Reclaim Behavior**: explains read-only mounts, ownership, access modes and what happens to a volume when its claim is deleted.
3. **Host Paths, Backups And The Data Lifecycle**: explains host path volumes, Pod Security Admission, snapshots, encryption at rest and the limits of deletion.

## Before you start

You need Kubernetes basics: namespaces, Deployments, Services, pods and the commands `kubectl get`, `kubectl apply` and `kubectl describe`. The playground is a kind cluster running Kubernetes 1.35. `kubectl` already points at it as the cluster administrator.

The playground has the Starfleet workloads, a service account `runner` that can only read pods, and the default storage class `standard`. You create claims and pods yourself and see who can mount which data.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
