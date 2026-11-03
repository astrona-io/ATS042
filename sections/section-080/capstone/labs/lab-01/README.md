---
estimated_duration: 35m
---

# Capstone: Protect A Backup Namespace

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Capstone for the etcd section. In the namespace `vault`, two Deployments mount node paths that hold the etcd data and keys, `backup-ops` has every verb on every Secret, all authenticated users can read Secrets, a credential sits in a ConfigMap and the Secret `archive-key` can still be changed.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-080/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-080/capstone/labs/lab-01
astrona destroy ats-042-capstone-080
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-vault-no-host-paths.sh` | exporter and restore mount no host path and have ready replicas |
| `validate-backup-ops-one-secret.sh` | backup-ops gets archive-key in vault and nothing else |
| `validate-groups-denied.sh` | authenticated and unauthenticated groups cannot read Secrets in vault or kube-system |
| `validate-access-key-in-secret.sh` | the access key moved to a Secret and exporter reads it from there |
| `validate-archive-key-immutable.sh` | archive-key is immutable and keeps its data |
