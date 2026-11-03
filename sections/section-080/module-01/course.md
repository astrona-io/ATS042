---
draft: true
exam_objectives:
  - Etcd
---
# Etcd And Stored Cluster Data

Etcd is a key-value database that stores the state of the cluster. The API server reads and writes it and applies authentication, authorization and admission to every request. This module explains how the connection is protected, how Secrets are stored and encrypted at rest, who can still read them through the API, and what snapshots and restores mean for security and recovery.

Keep one sentence in mind: anything that can read etcd, its files or its backups can read every Secret in the cluster.

## Learning objectives

After this module you can:

- Explain why a client of etcd skips the checks of the API server.
- Name the etcd flags that require certificate authentication for clients and peers.
- Identify the node paths that hold the database and the keys.
- Explain what encryption at rest protects and what it does not.
- Describe how to enable and rotate keys for encryption at rest in the right order.
- Explain which RBAC rights return Secret contents and how to narrow them.
- Calculate quorum and explain why replication is not a backup.
- Describe what a snapshot contains and what a restore does not bring back.

## What the parts cover

1. **Protecting The Cluster Datastore**: explains how etcd and the API server connect, which settings protect the connection and which node files open it.
2. **Secrets And Encryption At Rest**: explains how Secrets are stored, what encryption at rest does and does not do, and how to enable and rotate it.
3. **Snapshots, Quorum And Recovery**: explains quorum, snapshots, the sensitivity of backups and what a restore brings back.

## Before you start

You need Kubernetes basics: namespaces, Deployments, Services, pods and the commands `kubectl get`, `kubectl apply` and `kubectl describe`. The playground is a kind cluster running Kubernetes 1.35. `kubectl` already points at it as the cluster administrator.

The playground has the Starfleet workloads, a Secret `warp-key` and a service account `archivist` that can read Secrets in every namespace. You can read the etcd Pod settings through the API, test a hostPath Pod with a dry run and narrow the role.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
