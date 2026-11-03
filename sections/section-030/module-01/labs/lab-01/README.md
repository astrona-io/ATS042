---
estimated_duration: 25m
---

# Lab: Protect A Restricted Node Pool

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Graded lab for the scheduler module. One worker is a restricted node with a label and a taint. The workload that must run there is Pending, a service account can relabel nodes, and nothing stops a pod from naming its node directly.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-030/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-030/module-01/labs/lab-01
astrona destroy ats-042-lab-030-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-vault-on-restricted-node.sh` | The vault pod runs on the restricted node |
| `validate-other-workloads-off-restricted-node.sh` | No other workload tolerates the restricted taint |
| `validate-intern-cannot-change-nodes.sh` | intern cannot patch or update nodes but can still read them |
| `validate-nodename-rejected-in-outpost.sh` | A pod with spec.nodeName is rejected in outpost |
