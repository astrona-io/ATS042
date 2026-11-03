---
draft: true
exam_objectives:
  - API Server
---
# Summary

The API server checks every request in three steps. Authentication establishes the identity from a client certificate, a token or an authentication webhook, or marks the request anonymous. Authorization checks the identity, the verb, the resource, the API group and the namespace against the active authorizers, mostly RBAC. Admission then mutates or validates the object before the server stores it. A request that fails one step never reaches the next.

RBAC is allow-only and additive. A Role holds rules for one namespace, a ClusterRole holds rules that are not tied to a namespace, and a binding gives the rules to subjects. A RoleBinding that points at a ClusterRole grants the rules only in its own namespace. Over-broad bindings, such as a role granted to the group system:unauthenticated or cluster-admin granted to a pipeline, are found by listing bindings and checking identities with kubectl auth can-i and the --as flag.

Admission policy is a separate layer. A ValidatingAdmissionPolicy evaluates Common Expression Language (CEL) expressions on each matching request, and a binding decides where the policy applies and whether it denies, warns or audits. The failure policy decides what happens when the policy cannot be evaluated. The audit policy records requests at the levels None, Metadata, Request and RequestResponse, so a log that records bodies can itself hold secrets.

Key facts:

- Authentication, authorization and admission are three different checks, in that order.
- Encryption in transit does not replace permission checks.
- Admission can reject an object that RBAC allowed the caller to submit.
- Audit records show API requests, not what an application did afterwards.

<!-- astrona:playground:destroy -->
