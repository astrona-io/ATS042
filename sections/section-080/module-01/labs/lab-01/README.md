---
estimated_duration: 25m
---

# Lab: Close Paths To Stored Cluster Data

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Graded lab for the etcd module. The Deployment `snapshotter` in `archive` mounts the etcd data and key directories from the node, its service account reads every Secret in the cluster, every authenticated user can read Secrets in `archive` and a password sits in a ConfigMap.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-080/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-080/module-01/labs/lab-01
astrona destroy ats-042-lab-080-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-snapshotter-no-host-paths.sh` | snapshotter mounts no host path and has a ready replica |
| `validate-snapshotter-one-secret.sh` | snapshotter gets backup-key in archive and cannot read other Secrets |
| `validate-authenticated-denied.sh` | authenticated and unauthenticated groups cannot read Secrets in archive |
| `validate-password-in-secret.sh` | the password moved to a Secret and the container reads it from there |
