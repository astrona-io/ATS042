---
estimated_duration: 30m
---

# Lab: Issue And Narrow Client Credentials

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Graded lab for the client credential module. In `dock`, two certificate requests are pending, the service account `courier` holds a never-expiring token and a cluster-admin binding, and a kubeconfig with disabled verification sits in a ConfigMap.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-100/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-100/module-01/labs/lab-01
astrona destroy ats-042-lab-100-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-csr-decisions.sh` | ensign is approved and signed, intruder is denied |
| `validate-ensign-pod-reader.sh` | ensign reads pods in dock and nothing else |
| `validate-courier-narrowed.sh` | courier has no legacy token and only reads pods in dock |
| `validate-kubeconfig-secret.sh` | the kubeconfig is a Secret that verifies the server |
