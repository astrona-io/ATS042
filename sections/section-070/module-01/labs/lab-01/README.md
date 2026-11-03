---
estimated_duration: 25m
---

# Lab: Harden A Workload And Its Credentials

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Graded lab for the pod module. The Deployment `relay` in `hangar` runs privileged on the host network with a host path, mounts an API token and its service account can read Secrets and exec into pods.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-070/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-070/module-01/labs/lab-01
astrona destroy ats-042-lab-070-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-relay-hardened.sh` | relay drops privileges and host access and has a ready replica |
| `validate-relay-no-token.sh` | relay mounts no API token |
| `validate-relay-role-reduced.sh` | relay reads ConfigMaps but not Secrets and cannot exec |
| `validate-hangar-restricted.sh` | hangar enforces the restricted standard and rejects a privileged pod |
