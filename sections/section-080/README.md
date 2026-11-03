---
draft: true
exam_objectives:
  - Etcd
---
# Etcd And Stored Cluster Data

Etcd holds every object of the cluster, including every Secret. The API server is the only component that should reach it, so anything that opens a second path to the database or to its backups also opens every credential that it stores.

## Learning outcomes

- Explain why a client of etcd skips the checks of the API server.
- Name the etcd flags that require certificate authentication for clients and peers.
- Identify the node paths that hold the database and the keys.
- Explain what encryption at rest protects and what it does not.
- Describe how to enable and rotate keys for encryption at rest in the right order.
- Explain which RBAC rights return Secret contents and how to narrow them.
- Calculate quorum and explain why replication is not a backup.
- Describe what a snapshot contains and what a restore does not bring back.

## What is in this section

The section has one module, Etcd And Stored Cluster Data. It has 3 reading parts, a summary and a playground: a cluster to read the etcd configuration, inspect Secrets and narrow Secret read rights. A graded lab follows the reading part it practises. A capstone lab closes the section with a new scenario, and a knowledge check of ten questions follows the capstone.
