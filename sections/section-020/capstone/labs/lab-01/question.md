# Question

Solve this question on: `terminal`

This is the section capstone: one integrated task without step-by-step guidance.

The namespace `harbor` runs an operator with the service account `ops-operator`. Make the namespace safe and restore its workloads. Do not delete any object that exists at the start.

1. The operator must be able to `get`, `list`, `watch`, `update` and `patch` Deployments in `harbor`, and `get`, `list` and `watch` ConfigMaps in `harbor`. It must not use any other verb or resource, and it must not act outside `harbor`. Remove its cluster-wide grants.

2. The operator must not be able to read Secrets in any namespace, and it must hold neither `escalate` nor `bind`.

3. The Deployment `harbor-web` must run its two replicas. It is not running them today.

4. Finished Jobs from the CronJob `nightly-backup` must be removed automatically 300 seconds or less after they finish, and the CronJob must keep at most two successful Jobs.

`kubectl` points at the cluster as the cluster administrator.
