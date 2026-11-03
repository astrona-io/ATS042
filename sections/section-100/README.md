---
draft: true
exam_objectives:
  - Client Security
---
# Client Credentials And Configuration

Every person and every job that talks to the cluster does so with a credential from a client file. The cluster can only protect itself if those credentials are issued with care, kept narrow and short-lived, and removed when they leak.

## Learning outcomes

- Describe the parts of a kubeconfig file and what each one controls.
- Explain what skipping TLS verification gives up.
- Explain why a kubeconfig from an unknown source is a risk.
- Explain how a certificate subject maps to a user and groups.
- Walk through the request, approval and signing of a client certificate.
- Name the permissions that control certificate approval and token creation.
- Compare short-lived tokens with legacy token Secrets.
- Remove the access of a leaked credential in the correct order.

## What is in this section

The section has one module, Client Credentials And Configuration. It has 3 reading parts, a summary and a playground: a cluster to read a kubeconfig, sign a client certificate and request service account tokens. A graded lab follows the reading part it practises. A capstone lab closes the section with a new scenario, and a knowledge check of ten questions follows the capstone.
