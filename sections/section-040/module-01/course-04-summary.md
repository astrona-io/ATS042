---
draft: true
exam_objectives:
  - Kubelet
---
# Summary

The kubelet runs on each node, starts the pods that the API server has assigned to that node, reports their status and serves its own HTTPS API on port 10250. Callers of that API are authenticated by client certificate, bearer token or, if allowed, anonymously. With Webhook authorization the kubelet asks the API server whether the caller may act on the node subresource that matches the path, for example `nodes/metrics`, `nodes/stats`, `nodes/log` or `nodes/proxy`.

The rights that reach the kubelet are strong. `nodes/proxy` forwards requests to the kubelet API. `pods/exec`, `pods/attach` and `pods/portforward` open a stream to a container through the kubelet. Grant them by namespace and by named subject, and use the narrow subresources such as `nodes/metrics` for monitoring. Disable anonymous access, use Webhook authorization and set the read-only port to 0.

A node proves its identity with a client certificate for the user `system:node:<name>` in the group `system:nodes`. The Node authorizer and the NodeRestriction admission plugin limit that identity to the objects of the pods on its own node. Certificates come from CertificateSigningRequests. Approval is a separate right, `update` on `certificatesigningrequests/approval` plus `approve` on `signers`, and it must not be broad.

Key facts:

- A user who cannot read a Secret through the API may still reach data through a broad kubelet path.
- Host-level access exposes the data of every pod on the node.
- A hostPath mount of the kubelet directory exposes pod volumes and projected tokens.

<!-- astrona:playground:destroy -->
