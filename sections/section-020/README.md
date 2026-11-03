---
draft: true
exam_objectives:
  - Controller Manager
---
# Controller Manager

Controllers are the programs that make the cluster match its declared state. The kube-controller-manager runs the built-in ones, and operators add custom ones. Each controller acts through the API with an identity, so the permissions of that identity define what a compromised controller can change.

## Learning outcomes

- Explain the reconcile loop and name the built-in controllers that matter for security.
- Read the kube-controller-manager flags that affect security from its static pod.
- Explain why use-service-account-credentials gives each controller its own identity.
- Write least-privilege RBAC for a custom controller, including resourceNames and namespace scope.
- Explain the escalate, bind and impersonate verbs and why a controller should not hold them.
- Use ownerReferences and garbage collection, and explain what a paused Deployment does.
- Describe what stops working, and what keeps running, when the controller manager is unavailable.

## What is in this section

The section has one module, Controller Manager Authority. It has 3 reading parts, a summary and a playground: a cluster with a custom controller Deployment whose service account is bound to a wildcard ClusterRole, and a service account that can escalate. A graded lab follows the reading part it practises. A capstone lab closes the section with a new scenario, and a knowledge check of ten questions follows the capstone.
