---
draft: true
exam_objectives:
  - Kubelet
---
# Summary

The kubelet coordinates assigned workloads and holds node authority needed for their execution. Node identities, bootstrap trust and API grants must be constrained to the intended responsibilities.

Direct kubelet endpoints and diagnostic operations need independent protection. Host-level compromise can undermine container confidentiality and integrity, so recovery may require restoring node trust as well as workload configuration.
