---
draft: true
exam_objectives:
  - API Server
---
# API Server Security Boundaries

The kube-apiserver is the only component that clients use to read and change cluster state, and it is the only component that writes to the datastore. If an attacker controls what the API server accepts, the attacker controls the cluster. This module teaches the three checks every request passes (authentication, authorization and admission), the settings behind each check, the audit log that records the result, and the mistakes that leave the server open.

Keep one sentence in mind: authentication says who you are, authorization says what that identity may do, and admission says whether the object itself is acceptable.

## Learning objectives

After this module you can:

- Name the order of the request path and which check rejects a given request.
- Explain the authentication methods the API server supports and what anonymous access means.
- Write a Role and a RoleBinding that give a service account only the verbs it needs.
- Find and remove bindings that grant rights to system:unauthenticated or to broad groups.
- Explain mutating and validating admission and write a ValidatingAdmissionPolicy with a binding.
- Explain what an audit policy records and why audit data is sensitive.
- Explain why TLS verification, narrow network exposure and short-lived credentials are needed together.

## What the parts cover

1. **Protecting The Cluster API**: follows one request through authentication, authorization and admission, reads the API server flags and shows how transport and endpoint exposure fit in.
2. **Authorization And Least Privilege With RBAC**: explains how RBAC evaluates a request, how roles and bindings are scoped, how to find over-broad grants including anonymous access, and how service accounts get their tokens.
3. **Admission Control And Audit Evidence**: explains mutating and validating admission, the ValidatingAdmissionPolicy object, failure policy and the audit policy that records what happened.

## Before you start

You need Kubernetes basics: namespaces, Deployments, Services, pods and the commands `kubectl get`, `kubectl apply` and `kubectl describe`. The playground is a kind cluster running Kubernetes 1.35. `kubectl` already points at it as the cluster administrator.

The playground has the Starfleet example workloads: `scout`, `probe` and `shuttle` in `starfleet`, and `drifter` in `outpost`. It also has a service account `ci-deployer` in `starfleet` that is bound to `cluster-admin`, and a ClusterRoleBinding `public-reader` that gives the built-in `view` role to the group `system:unauthenticated`. Both faults are there on purpose.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
