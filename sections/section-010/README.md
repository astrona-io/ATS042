---
draft: true
exam_objectives:
  - API Server
---
# API Server

The kube-apiserver is the front door of the cluster. Every user, controller, kubelet and pipeline talks to it, and every change to cluster state passes through it. This section follows one request through the server and shows which setting decides each step.

## Learning outcomes

- Name the order of the request path and which check rejects a given request.
- Explain the authentication methods the API server supports and what anonymous access means.
- Write a Role and a RoleBinding that give a service account only the verbs it needs.
- Find and remove bindings that grant rights to system:unauthenticated or to broad groups.
- Explain mutating and validating admission and write a ValidatingAdmissionPolicy with a binding.
- Explain what an audit policy records and why audit data is sensitive.
- Explain why TLS verification, narrow network exposure and short-lived credentials are needed together.

## What is in this section

The section has one module, API Server Security Boundaries. It has 3 reading parts, a summary and a playground: a cluster with the Starfleet workloads, a pipeline service account that holds too many rights and an over-broad binding for unauthenticated users. A graded lab follows the reading part it practises. A capstone lab closes the section with a new scenario, and a knowledge check of ten questions follows the capstone.
