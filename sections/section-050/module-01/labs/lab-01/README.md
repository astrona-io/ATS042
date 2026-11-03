---
estimated_duration: 25m
---

# Lab: Remove Host Access And Enforce A Pod Security Level

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Graded lab for the container runtime module. A Deployment in `outpost` runs privileged with the host process namespace and a mount of the runtime directory, and the namespace has no Pod Security label.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-050/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-050/module-01/labs/lab-01
astrona destroy ats-042-lab-050-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-courier-not-privileged.sh` | courier is not privileged and drops all capabilities |
| `validate-courier-no-host-access.sh` | courier has no hostPath volume or host namespace and is ready |
| `validate-outpost-enforces-baseline.sh` | outpost enforces baseline or restricted and rejects a privileged pod |
| `validate-sandboxed-runtimeclass.sh` | RuntimeClass sandboxed has the handler runsc and the overhead |
