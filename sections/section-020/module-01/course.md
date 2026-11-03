---
draft: true
exam_objectives:
  - Controller Manager
---
# Controller Manager Authority

A Deployment says "run three replicas", and a controller makes it true. The kube-controller-manager runs the built-in controllers in one process. It watches objects through the API server, compares the declared state with the observed state and writes changes until they match. This module teaches what each controller is allowed to do, how its identity is set up, how ownership drives cleanup, and what breaks when reconciliation stops or a controller identity is abused.

Keep one sentence in mind: a controller can do exactly what its API permissions allow, so the permissions are the security boundary.

## Learning objectives

After this module you can:

- Explain the reconcile loop and name the built-in controllers that matter for security.
- Read the kube-controller-manager flags that affect security from its static pod.
- Explain why use-service-account-credentials gives each controller its own identity.
- Write least-privilege RBAC for a custom controller, including resourceNames and namespace scope.
- Explain the escalate, bind and impersonate verbs and why a controller should not hold them.
- Use ownerReferences and garbage collection, and explain what a paused Deployment does.
- Describe what stops working, and what keeps running, when the controller manager is unavailable.

## What the parts cover

1. **Securing Reconciliation Components**: explains the reconcile loop, the kube-controller-manager process and the flags that control its identity and exposure.
2. **Controller Identities And RBAC**: explains the built-in controller roles, how a custom controller gets its permissions, and the verbs that allow privilege escalation.
3. **Ownership, Recovery And Failure**: explains ownerReferences, garbage collection, paused Deployments, TTL cleanup and what happens when the controller manager is down or compromised.

## Before you start

You need Kubernetes basics: namespaces, Deployments, Services, pods and the commands `kubectl get`, `kubectl apply` and `kubectl describe`. The playground is a kind cluster running Kubernetes 1.35. `kubectl` already points at it as the cluster administrator.

The playground has a Deployment `fleet-controller` in `starfleet` that stands in for a custom controller. Its service account `fleet-controller` is bound to a ClusterRole with `*` on `*`. A service account `intern` can create roles and has the `escalate` and `bind` verbs. A ConfigMap `fleet-state`, a ConfigMap `fleet-notes` and a Secret `fleet-key` are in `starfleet`.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
