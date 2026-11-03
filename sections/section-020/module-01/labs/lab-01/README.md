---
estimated_duration: 25m
---

# Lab: Limit A Custom Controller With RBAC And Ownership

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Graded lab for the controller manager module. A stand-in custom controller runs with a wildcard ClusterRole, a second service account can escalate privileges, and a ConfigMap that belongs to the controller has no owner.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-020/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-020/module-01/labs/lab-01
astrona destroy ats-042-lab-020-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-controller-scoped-to-namespace.sh` | fleet-controller reads ConfigMaps in starfleet only |
| `validate-controller-writes-only-fleet-state.sh` | fleet-controller changes only the ConfigMap fleet-state |
| `validate-controller-no-secrets.sh` | fleet-controller cannot read Secrets |
| `validate-intern-cannot-escalate.sh` | intern holds neither escalate nor bind and can still read pods |
| `validate-fleet-state-owned-by-deployment.sh` | The ConfigMap fleet-state is owned by the Deployment fleet-controller |
