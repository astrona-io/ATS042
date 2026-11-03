---
estimated_duration: 35m
---

# Capstone: Secure A Kitchen Namespace

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Capstone for the pod section. In the namespace `galley`, the Deployments `pantry` and `oven` break several settings, all service accounts carry API tokens and the operator `chef` can read Secrets, exec into pods and add ephemeral containers.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-070/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-070/capstone/labs/lab-01
astrona destroy ats-042-capstone-070
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-pantry-hardened.sh` | pantry drops privileges and host access and has a ready replica |
| `validate-oven-hardened.sh` | oven drops privileges and host access and has a ready replica |
| `validate-galley-no-tokens.sh` | no workload in galley mounts an API token |
| `validate-chef-read-only.sh` | chef reads pods and logs and cannot read Secrets, exec, debug or write pods |
| `validate-galley-restricted.sh` | galley enforces the restricted standard and rejects a privileged pod |
