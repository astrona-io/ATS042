---
draft: true
exam_objectives:
  - Pod
---
# Pod-Level Privileges And Application Access

A Pod groups containers for placement and shared networking. The grouping is useful for tightly coupled processes, but it also creates security consequences: helpers can communicate locally, share selected volumes and influence the application's operating environment. Pod membership should reflect a deliberate trust relationship.

## Shared Network And Storage

Containers in a normal Pod share a network namespace. A helper can reach listeners exposed on loopback within that Pod, so an application should not treat every local caller as automatically trustworthy merely because external access is blocked. Both containers also share port space and need compatible listeners.

Filesystem sharing requires explicit mounts. A shared volume can contain application data or credentials, and a helper with write access can change what the main process reads. Mount sensitive data only where needed and distinguish read access from write access. An image's separate filesystem does not automatically protect a deliberately shared volume.

## Identity And application programming interface (API) Tokens

The Pod uses a ServiceAccount for workload API identity when configured. Automatically mounted credentials can give a compromised process a path to the cluster API. Remove unnecessary token access and scope the identity's grants. A workload that never calls the API does not need a convenient administrative credential inside its process environment.

Short-lived tokens and audience restrictions reduce selected exposure, but a valid stolen token can still be misused within its scope. Application database credentials have the same need for narrow authority and careful handling. role-based access control (RBAC) protects Kubernetes actions; it does not define every permission in an external data service.

## Privileges And Host Interfaces

A security context can restrict users, capability sets, privilege escalation, system calls and writable filesystem behavior. Admission can reject disallowed declared settings. These protections must cover relevant main, init and helper containers rather than only the most visible application.

Host network access, host namespaces, host paths and device exposure change the ordinary containment assumptions. A container can receive a powerful interface without needing a broad Kubernetes role. A runtime socket mount is an example of authority that should be considered beyond API token permissions.

A privileged Pod should therefore be treated as a special operating need with defined ownership and controls, not as a routine fix for startup errors. A permission error may require appropriate file ownership or a narrow capability instead of unrestricted execution.

## State And Replacement

Deleting a suspicious Pod removes one object and process environment, while its controller can create another from the same template. If the image, configuration or credential source remains compromised, replacement repeats the problem. Restore trusted inputs and revoke exposed authority before assuming the new Pod is safe.

Temporary Pod data can disappear during replacement, while persistent or external data can retain malicious changes. Incident scope includes those lifecycles. A clean object name and a new identifier do not establish that dependencies or stored data are trustworthy again.

## A Reviewable Pod Security Decision

Identify what each container must read, write, connect to and administer. Then examine the shared resources, identity grants, runtime privileges and admission policy that permit those actions. The strongest explanation includes both normal requirements and what a compromised process could still do through legitimate access.

Pod security is therefore a combination of declared configuration, enforced execution and application trust. Passing one profile check is valuable but does not replace the full data and identity contract.

## Common pitfalls

> [!WARNING]
> Containers sharing a Pod have an explicit trust relationship. Replacing a Pod does not remove compromised images, external data or exposed credentials that remain in its sources and dependencies.
