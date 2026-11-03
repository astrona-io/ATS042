---
draft: true
exam_objectives:
  - Client Security
---
# Client Credentials And Configuration

A client holds a kubeconfig file that names a server, a way to verify it and a credential. This module explains how that file is built and what it exposes, how a client certificate is requested, reviewed and signed through the certificate API, and how service account tokens are issued, bound and withdrawn. It also covers how to give automation a credential that does only one job.

Keep one sentence in mind: a credential proves identity, a role limits what that identity does, and the cluster cannot take back a certificate once it is signed.

## Learning objectives

After this module you can:

- Describe the parts of a kubeconfig file and what each one controls.
- Explain what skipping TLS verification gives up.
- Explain why a kubeconfig from an unknown source is a risk.
- Explain how a certificate subject maps to a user and groups.
- Walk through the request, approval and signing of a client certificate.
- Name the permissions that control certificate approval and token creation.
- Compare short-lived tokens with legacy token Secrets.
- Remove the access of a leaked credential in the correct order.

## What the parts cover

1. **Kubeconfig, Contexts And Client Trust**: explains the structure of a kubeconfig file, how the client verifies the server and what leaks when a file is shared.
2. **Client Certificates And Signing Requests**: explains how a certificate becomes an identity, how a signing request is approved and what cannot be undone.
3. **Service Account Tokens And Automation Credentials**: explains how tokens are issued, bound and removed, and how to give automation narrow credentials.

## Before you start

You need Kubernetes basics: namespaces, Deployments, Services, pods and the commands `kubectl get`, `kubectl apply` and `kubectl describe`. The playground is a kind cluster running Kubernetes 1.35. `kubectl` already points at it as the cluster administrator.

The playground has the Starfleet workloads and a service account `runner` that may read pods in `starfleet`. You can inspect the kubeconfig, request and approve a certificate for a new user and ask for short-lived and long-lived tokens.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
