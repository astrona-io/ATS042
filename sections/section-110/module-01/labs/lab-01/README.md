---
estimated_duration: 30m
---

# Lab: Reduce Who Can Reach A Volume

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Graded lab for the storage module. In `ledger`, three Deployments mount the claim `records` read-write, the volume behind it is deleted with the claim, and the service account `clerk` may create pods and Deployments.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-110/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-110/module-01/labs/lab-01
astrona destroy ats-042-lab-110-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-inspector-unmounted.sh` | inspector does not mount the claim |
| `validate-reporter-read-only.sh` | reporter mounts records read-only |
| `validate-records-retained.sh` | the volume behind records is retained |
| `validate-clerk-no-workloads.sh` | clerk reads claims and starts nothing |
| `validate-collector-intact.sh` | collector still writes to a bound claim |
