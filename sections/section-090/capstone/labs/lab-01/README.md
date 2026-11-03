---
estimated_duration: 40m
---

# Capstone: Segment A Two Namespace Application

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Capstone for the network section. The namespaces `bay` and `quay` hold a gate, a store, a crane and three clients in `quay`. The graders send real requests between them.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-090/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-090/capstone/labs/lab-01
astrona destroy ats-042-capstone-090
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-gate-from-crane-only.sh` | only crane reaches gate |
| `validate-store-crane-and-auditor.sh` | crane and auditor reach store, stranger does not |
| `validate-bay-default-deny.sh` | a policy in bay isolates every Pod for ingress |
| `validate-crane-egress-limited.sh` | crane reaches gate and store by name and nothing else |
| `validate-quay-untouched.sh` | auditor and stranger still reach lighthouse |
