---
draft: true
exam_objectives:
  - Controller Manager
---
# Summary

A controller is a loop that watches objects through the API server, compares the declared state with the observed state and writes changes until the two match. The kube-controller-manager runs the built-in controllers, for example the Deployment, ReplicaSet, Job, node and garbage collector controllers. A custom controller or operator runs as a normal workload with its own service account.

Every controller acts through RBAC. With `--use-service-account-credentials=true`, each built-in controller uses its own service account and the matching `system:controller:` role, so a single compromised loop does not hold the rights of all of them. A custom controller needs a Role or ClusterRole that names only the resources and verbs it reconciles. The verbs `escalate`, `bind` and `impersonate`, and `list` or `watch` on Secrets, turn a controller compromise into a cluster compromise.

Ownership connects objects. An `ownerReference` makes the garbage collector delete a dependent object when its owner is deleted. A paused Deployment is not reconciled, and a Job or CronJob history that is never cleaned up keeps objects and their data. If the controller manager stops, running pods keep running, but replacement pods, scaling and cleanup stop until it returns.

Key facts:

- Controller permissions are API permissions and nothing more.
- Scope a controller by namespace, resource and resource name.
- Restoring a controller does not repair application data.
- The controller manager exposes its secure port and a profiling endpoint that should not be reachable by workloads.

<!-- astrona:playground:destroy -->
