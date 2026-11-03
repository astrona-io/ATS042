---
estimated_duration: 25m
---

# Lab: Close Anonymous Access And Add Admission Policy

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Graded lab for the API server module. The cluster starts with a binding that exposes pods to unauthenticated users, a pipeline service account bound to `cluster-admin`, no admission policy in `outpost` and a Deployment that mounts an API token it never uses.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-010/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-042-lab-010-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-anonymous-access-removed.sh` | Unauthenticated callers cannot read pods or secrets |
| `validate-ci-deployer-can-manage-deployments.sh` | ci-deployer can read, create, update and patch Deployments in starfleet |
| `validate-ci-deployer-least-privilege.sh` | ci-deployer has no rights beyond Deployments in starfleet |
| `validate-privileged-pod-rejected.sh` | A privileged pod is rejected in outpost |
| `validate-ordinary-pod-still-accepted.sh` | An ordinary pod is still accepted in outpost |
| `validate-probe-token-not-mounted.sh` | The probe pods do not mount a service account token |
