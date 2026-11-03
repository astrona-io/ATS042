---
estimated_duration: 30m
---

# Capstone: Close Node Access Paths In A Namespace

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Capstone for the kubelet section. In the namespace `deck`, an auditor holds a wildcard on node subresources, an operator can exec anywhere, every authenticated user can approve certificates and a Deployment mounts the kubelet directory from the host.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-040/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-040/capstone/labs/lab-01
astrona destroy ats-042-capstone-040
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-auditor-narrow-node-access.sh` | auditor reads nodes, metrics and stats only |
| `validate-ops-exec-only-in-deck.sh` | ops can exec only in deck and cannot attach or port-forward |
| `validate-csr-approval-limited.sh` | Only the group pki-admins can approve certificate requests |
| `validate-inspector-no-hostpath.sh` | inspector has no hostPath volume and is ready |
