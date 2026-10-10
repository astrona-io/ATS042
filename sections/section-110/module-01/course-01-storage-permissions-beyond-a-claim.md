---
draft: true
exam_objectives:
  - Storage
---
# Storage Permissions Beyond A Claim

A persistent claim gives `probe` a storage association, but it does not fully define who can inspect its data. Kubernetes permissions, node access, storage driver credentials and backend account controls all contribute to the actual boundary. Secure storage requires tracing that full path.

## Resource Permission And Data Access

A PersistentVolumeClaim (PVC) is a namespaced request, while a PersistentVolume (PV) represents provisioned storage. Permission to read their application programming interface (API) records differs from permission to read the mounted file contents. A caller who can create a workload referencing accessible storage can obtain another route to data, depending on admission and storage configuration.

Volume access modes describe supported mounting arrangements. ReadWriteOnce refers to one node rather than universally one Pod, and shared-write support does not implement application record authorization. Filesystem permissions and application data rules still matter after the mount succeeds.

The Container Storage Interface (CSI) driver and backend integration can hold credentials with authority to create, attach or remove storage. Protect those identities and the node components that expose volumes to processes. A broadly compromised driver or storage administrator can have consequences beyond one namespace.

## Confidentiality At Rest And In Use

At-rest encryption protects stored bytes under its defined key and access model. An authorized mounted reader receives usable data, so encryption does not decide whether the process should have that access. A host administrator can also affect the trusted execution environment where plaintext is used.

Snapshots and backups can create additional copies with different readers and retention. A confidential volume copied into a broadly accessible backup location gains a new disclosure path. Keys, snapshot permissions and restore identities need explicit ownership and scope.

Deleting a Pod does not necessarily remove persistent data. Deleting a claim can trigger Retain or Delete reclamation depending on the applicable policy. Neither operation should be described as guaranteed secure erasure without considering the backend, snapshots and retained copies.

## Integrity And Recovery

A compromised application with write access can corrupt or replace records even if storage is encrypted. Replication can preserve that unwanted change across members. Historical recovery needs a suitable backup or other recovery point, while application consistency can require coordination across data stores.

A read-only mount reduces modification through that path but still exposes readable contents. A filesystem mode differs from a raw block mode, and both need compatible process behavior. Choose the access required rather than granting broader storage authority simply to avoid permission errors.

## Working Through A Data Exposure

Suppose a report volume survives replacement correctly, but an unnecessary helper container mounts it read-write. That helper becomes part of the data trust boundary. If compromised, it can disclose or change reports without changing the PVC's apparently healthy bound status.

The correction removes unnecessary mounts and permissions, investigates accessed data and restores trustworthy content if needed. A new application Pod is not sufficient evidence that the persistent data is clean. Review snapshots and other copies as part of the same data lifecycle.

The storage decision should identify the readers, writers, administrative identities, encryption keys and recovery process. Binding, mounting and persistence are useful operating properties; confidentiality and integrity need their own evidence.

## Common pitfalls

> [!WARNING]
> A bound claim and encrypted backend do not prove every mounted reader is authorized. Snapshots, helper mounts and driver credentials create additional data-access boundaries.
