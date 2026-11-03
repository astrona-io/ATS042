---
estimated_duration: 30m
---

# Capstone: Secure An Operator And Restore Reconciliation

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Capstone for the controller manager section. The namespace `harbor` runs an operator service account with cluster-wide Secret access and escalation rights, a Deployment that is paused and a CronJob that keeps twenty old Jobs.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-020/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-020/capstone/labs/lab-01
astrona destroy ats-042-capstone-020
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-operator-can-do-its-work.sh` | ops-operator manages Deployments and reads ConfigMaps in harbor |
| `validate-operator-namespace-only.sh` | ops-operator has no rights outside harbor and no extra verbs |
| `validate-operator-no-secrets-or-escalation.sh` | ops-operator cannot read Secrets or escalate |
| `validate-harbor-web-reconciled.sh` | The Deployment harbor-web runs two ready replicas |
| `validate-backup-jobs-cleaned-up.sh` | The CronJob nightly-backup cleans up finished Jobs |
