# Question

Solve this question on: `terminal`

This is the section capstone: one integrated task without step-by-step guidance.

The namespace `depot` holds the claim `manifest`. The Deployment `writer` writes to it and must keep doing so. The Deployment `auditor` only reads it. The Deployment `scanner` does not need the claim, but it mounts a directory of the node. The service account `intern` is meant to look at claims. Do not delete the claim, and do not change `writer`.

1. `scanner` must not mount any directory of the node.

2. `auditor` must keep mounting `manifest` and mount it read-only.

3. The namespace `depot` must refuse hostPath volumes. A hostPath pod must be rejected by the API server, and the existing Deployments must stay ready.

4. The volume behind `manifest` must keep its data when the claim is deleted.

5. `intern` must read claims in `depot` and must not be able to create pods or jobs.

`kubectl` points at the cluster as the cluster administrator.
