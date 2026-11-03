---
estimated_duration: 30m
---

# Capstone: Restore Scheduling And Close Placement Bypasses

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Capstone for the scheduler section. The namespace `armada` has a Deployment that asks for 64 CPUs, two replicas that may share one node, a priority class that any pod can use and a service account that can bind pods and change nodes.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-030/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-030/capstone/labs/lab-01
astrona destroy ats-042-capstone-030
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-cargo-scheduled.sh` | The Deployment cargo runs two ready replicas |
| `validate-relay-spread.sh` | The relay replicas run on different nodes and the spread is required |
| `validate-urgent-class-limited.sh` | New pods cannot use the urgent priority class in armada |
| `validate-ops-cannot-bind-or-edit-nodes.sh` | armada-ops cannot create bindings or change nodes |
