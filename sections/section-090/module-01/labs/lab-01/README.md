---
estimated_duration: 30m
---

# Lab: Isolate Workloads With NetworkPolicy

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Graded lab for the network module. The cluster runs Calico and has no policies. The graders send real requests from `shuttle`, `visitor` and `drifter` and check which ones arrive.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-090/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-090/module-01/labs/lab-01
astrona destroy ats-042-lab-090-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-probe-only-shuttle.sh` | only shuttle reaches probe |
| `validate-scout-namespace-only.sh` | scout accepts the namespace starfleet only |
| `validate-shuttle-egress-limited.sh` | shuttle reaches probe and scout by name and nothing else |
| `validate-outpost-untouched.sh` | drifter still reaches beacon |
