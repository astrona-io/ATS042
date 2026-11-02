---
draft: true
exam_objectives:
  - Controller Manager
---
# Securing Reconciliation Components

The controller manager runs control loops that maintain cluster state. Controllers observe resources and use the Kubernetes application programming interface (API) to create or change other objects. Their ability to reconcile workloads depends on identities, permissions and access to the desired state they manage.

## Why Controller Permissions Matter

A replica controller can request replacement Pods when managed replicas disappear. Other controllers handle nodes, endpoints or related lifecycle operations according to the cluster's design. These components need permissions appropriate to their jobs, but a controller's operational purpose does not make unrestricted authority harmless.

If a controller identity is compromised, an attacker can attempt the API operations that identity permits. The consequence depends on its actual grants and the resources it can influence. A controller managing one custom application's namespace has a different expected boundary from a powerful system controller managing cluster-wide resources.

Credential files and access to the host process therefore need protection. Administrative users who can read them may be able to act as the controller. Limiting network reachability helps reduce paths to component endpoints, but does not protect a credential already exposed through disk, process or diagnostic access.

## API-Based Behavior And Transport

Controllers ordinarily use the API server rather than writing directly into etcd. API authentication, authorization and admission still matter to their requests. A misconfigured grant can cause reconciliation failures, while a broad grant can increase compromise impact. Both outcomes need evidence of the actual rejected or accepted action.

Secure connections should verify the intended API endpoint. Serving or diagnostic endpoints should not be broadly exposed without an identified need and suitable protection. An endpoint described as operational can still reveal internal state or enable unwanted behavior depending on what it serves.

## Availability And Leadership

Control plane redundancy can provide another controller-manager instance. Leader election coordinates active responsibilities so replicated components do not independently behave as unrelated managers of the same work. This supports availability, but the mechanism itself needs working API access and reliable component configuration.

Existing containers can continue while a controller is unavailable, yet recovery and new changes can stall. If a managed Pod disappears during that interval, desired replicas may not be restored promptly. Component health and workload health are therefore related but not identical observations.

## A Controller Failure Scenario

Suppose desired replica count is three, but a controller repeatedly receives forbidden responses when trying to create the replacement. The missing Pod is a consequence of insufficient controller permission, not necessarily of a failed application image. Restoring the correct scoped grant should allow object creation, after which scheduling and startup still need to succeed.

Now consider the opposite: an exposed controller credential creates unwanted workloads. The controller's normal name does not make the requests legitimate. Audit evidence, actual bindings and affected resources establish what happened. Recovery should revoke or replace the compromised credential and restore reviewed intent without ignoring external effects.

Controllers restore resource state they understand. They do not automatically undo malicious data writes inside an application or recover all external transactions. Protect their authority, observe their requests and define recovery at both resource and application boundaries.

## Common pitfalls

> [!WARNING]
> A trusted system role can have a large compromise impact. Controller availability does not prove application health, and reconciliation does not automatically repair every external data effect.
