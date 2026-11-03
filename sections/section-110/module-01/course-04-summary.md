---
draft: true
exam_objectives:
  - Storage
---
# Summary

A PersistentVolumeClaim is a namespaced request for storage, a PersistentVolume is cluster-scoped storage, and a StorageClass describes how storage is created. The control plane binds one claim to one volume and records the pair in both objects. A pod names a claim in its own namespace and the kubelet mounts the volume. The Kubernetes API does not check whether the creator of the pod owns the data. Permission to read the claim object returns only its record. The right to create pods, workloads or exec sessions in the namespace is a right on every claim there.

A read-only mount makes the kubelet refuse writes, and it does not stop reads. Ownership fields such as the file system group change who can open files inside the volume and are no boundary against other pods. An access mode states what the volume supports. ReadWriteOnce means one node, so other pods on that node can mount the same claim, and only ReadWriteOncePod limits use to one pod. The reclaim policy decides what happens when the claim goes away. Delete removes the volume and the data. Retain leaves both and hands the cleaning to an administrator, who must clear old data before the volume is claimed again.

Host path volumes give a pod the files of the node, including credentials and sockets of other workloads. Pod Security Admission, set by namespace labels, rejects them under the baseline and restricted profiles when the label uses the enforce mode. Snapshots and backups are extra copies with their own readers and retention, and creating a claim from a snapshot is another way to read the data. Encryption at rest protects the medium and not a process that mounts the volume. Deleting a pod, claim or volume object does not prove that every copy is erased.

Key facts:

- Rights to create pods are rights on every claim in the namespace.
- Read-only mounts stop writes only.
- Retain keeps the data after the claim is deleted.
- Backups and snapshots are copies with their own readers.

<!-- astrona:playground:destroy -->
