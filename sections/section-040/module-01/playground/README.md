# Kubelet And Node Access: Playground

- **Slug:** ats-042-playground-040-01
- **Type:** Astrona playground, a clean environment with no task and no grading
- **Status:** UNTESTED. Checked only with `astrona validate`, `bash -n` and YAML parsing.

The playground starts a single-node cluster with three service accounts whose rights reach the kubelet and the certificate signing path.

## Run it

```sh
astrona run -c .
astrona destroy ats-042-playground-040-01
```

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `bootstrap/prepare.sh` | Applies the manifests and waits for the workloads |
| `manifests/` | Starting objects |
| `docs/overview.md` | The only learner page |
