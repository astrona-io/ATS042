# Question

Solve this question on: `terminal`

This is the section capstone: one integrated task without step-by-step guidance.

The new team namespace `orbit` is being onboarded. A review found the following problems. Fix all of them with Kubernetes objects.

1. Every authenticated user can edit objects in every namespace. Remove that access.

2. The service account `release-bot` in `orbit` must be able to create, `update` and `patch` Deployments and to read (`get`, `list`) pods in `orbit`. It must not be able to delete Deployments, read Secrets, or use any other resource. Its current Role uses wildcards.

3. The group `developers` must read Secrets in `orbit` only. Today it can read Secrets in every namespace.

4. Deployments in `orbit` must carry the label `team`. The API server must reject a Deployment in `orbit` that has no `team` label and accept one that has it. Use an admission policy.

5. Pods in `orbit` must meet the `baseline` Pod Security level at admission, and the namespace must warn about violations of `restricted`.

`kubectl` points at the cluster as the cluster administrator.
