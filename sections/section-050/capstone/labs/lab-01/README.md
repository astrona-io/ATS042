---
estimated_duration: 35m
---

# Capstone: Harden A Build Namespace

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Capstone for the container runtime section. The namespace `dock` runs three Deployments: one mounts the runtime directory of the node, one runs privileged with the host process namespace and one runs as root with no restrictions. The namespace has no Pod Security label.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-050/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-050/capstone/labs/lab-01
astrona destroy ats-042-capstone-050
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-loader-no-hostpath.sh` | loader has no hostPath volume |
| `validate-builder-unprivileged.sh` | builder is not privileged and uses no host namespace |
| `validate-dock-enforces-restricted.sh` | dock enforces the restricted standard |
| `validate-workloads-comply-and-run.sh` | all three Deployments are ready and set restricted-compatible security contexts |
| `validate-isolated-runtimeclass.sh` | RuntimeClass isolated has the handler, selector and overhead |
