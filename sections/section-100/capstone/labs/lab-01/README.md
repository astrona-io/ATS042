---
estimated_duration: 40m
---

# Capstone: Rotate Access For A Flight Crew

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Capstone for the client credential section. The namespace `deck` has two pending certificate requests, an automation account `loader` with a cluster-admin binding and a never-expiring token, and a kubeconfig in a ConfigMap that runs a shell command and skips verification.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-100/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-100/capstone/labs/lab-01
astrona destroy ats-042-capstone-100
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-pilot-csr-decisions.sh` | pilot is approved and signed, pilot-root is denied |
| `validate-flight-group-access.sh` | the group flight reads Deployments in deck and nothing else |
| `validate-loader-no-legacy-admin.sh` | loader has no legacy token and no cluster-wide rights |
| `validate-loader-patch-only.sh` | loader gets and patches Deployments in deck only |
| `validate-ci-kubeconfig-secret.sh` | the build kubeconfig is a Secret that verifies the server |
