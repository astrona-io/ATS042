---
estimated_duration: 25m
---

# Lab: Limit Rights That Reach The Kubelet

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Graded lab for the kubelet module. Three service accounts hold rights that reach the kubelet or the certificate signing path: a monitor with nodes/proxy, a debugger with cluster-wide exec and an intern that approves certificate requests.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-040/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-040/module-01/labs/lab-01
astrona destroy ats-042-lab-040-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-monitor-no-node-proxy.sh` | monitor cannot use nodes/proxy |
| `validate-monitor-keeps-metrics.sh` | monitor can still read nodes, metrics and stats |
| `validate-debugger-only-in-outpost.sh` | debugger execs only in outpost |
| `validate-intern-cannot-approve-csr.sh` | intern cannot approve certificate signing requests |
