---
draft: true
exam_objectives:
  - Etcd
---
# Summary

Etcd stores every object of the cluster under keys that start with a registry prefix. The API server is its only intended client and presents a client certificate. All authentication, authorization and admission happen in the API server, so a holder of the etcd client key can read and write any object without them. Etcd requires client certificates with the client certificate authentication flag, and it does the same for member connections with the peer flag. A separate certificate authority for etcd keeps other cluster certificates from being accepted.

Two node directories open etcd: the data directory with the database, and the certificates directory with the keys. A pod that mounts either through a host path reads them. The API accepts such a pod unless admission rejects host paths, so Pod Security Admission or an admission policy has to block them, and untrusted workloads must stay off control plane nodes.

The data of a Secret is base64 text, not encrypted text. Encryption at rest makes the API server encrypt selected resources before writing them to etcd. The first provider in the list encrypts new writes, and the others can only decode. It protects files and backups, and it does not change what an authorized API reader receives. Enabling it affects only new writes, so existing objects must be rewritten, and key rotation adds the new key, restarts the API servers, rewrites the objects and removes the old key last. The get, list and watch verbs on Secrets return contents, so a rule that grants list discloses every Secret in its scope. Immutable Secrets cannot be updated.

Etcd needs a majority of members to accept writes. Three members tolerate one failure and five tolerate two, and an even number adds no tolerance. Replication copies a wrong write to every member, so only backups restore an earlier state. A snapshot holds every object and, without encryption, every credential, so its storage and retention need the same care as the live data. A restore returns cluster objects only. It does not return persistent volume data or external systems.

Key facts:

- The etcd client key bypasses all API checks.
- Encryption at rest does not hide values from authorized API readers.
- Replication is not a backup.
- A leaked snapshot requires rotating the credentials it contained.

<!-- astrona:playground:destroy -->
