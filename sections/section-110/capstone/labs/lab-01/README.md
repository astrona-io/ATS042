---
estimated_duration: 40m
---

# Capstone: Secure The Depot Storage

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Capstone for the storage section. The namespace `depot` holds a claim with three workloads, one of which mounts a node directory, and a service account that can start pods and jobs.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-110/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-110/capstone/labs/lab-01
astrona destroy ats-042-capstone-110
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-scanner-no-hostpath.sh` | scanner mounts no node directory |
| `validate-auditor-read-only.sh` | auditor mounts manifest read-only |
| `validate-depot-refuses-hostpath.sh` | depot rejects hostPath pods and its Deployments stay ready |
| `validate-manifest-retained.sh` | the volume behind manifest is retained |
| `validate-intern-no-workloads.sh` | intern reads claims and starts nothing |
| `validate-writer-intact.sh` | writer still writes to a bound claim |
