---
draft: true
exam_objectives:
  - Storage
---
# Storage Access And Data Security

A persistent claim keeps data after a pod is replaced, and it hands that data to every pod that names the claim. Storage security means knowing every reader, every copy and every administrator in the path.

## Learning outcomes

- Describe how a claim, a volume and a storage class relate and how binding works.
- Explain why permission on a claim object does not control the data.
- Name the rights that give access to mounted data.
- Use read-only mounts and explain what they do not protect.
- Compare access modes and state what they promise.
- Explain the reclaim policies and the risk of each.
- Explain why host path volumes are dangerous and how Pod Security Admission refuses them.
- Explain what snapshots, backups and encryption at rest protect and what deletion leaves behind.

## What is in this section

The section has one module, Storage Access And Data Security. It has 3 reading parts, a summary and a playground: a cluster to create claims, mount them from several pods and follow a volume through deletion. A graded lab follows the reading part it practises. A capstone lab closes the section with a new scenario, and a knowledge check of ten questions follows the capstone.
