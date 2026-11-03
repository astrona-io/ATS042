---
estimated_duration: 30m
---

# Capstone: Secure A New Team Namespace At The API

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Capstone for the API server section. A new namespace `orbit` starts with a ClusterRoleBinding that gives edit rights to every authenticated user, a pipeline Role with wildcards, a cluster-wide secret-reading grant for developers and no admission rules.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-010/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-010/capstone/labs/lab-01
astrona destroy ats-042-capstone-010
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-everyone-edit-removed.sh` | Authenticated users cannot edit objects across namespaces |
| `validate-release-bot-least-privilege.sh` | release-bot has exactly the rights it needs in orbit |
| `validate-developers-secrets-scoped.sh` | developers read Secrets in orbit only |
| `validate-team-label-required.sh` | Deployments in orbit need a team label |
| `validate-orbit-pod-security-levels.sh` | orbit enforces baseline and warns about restricted |
