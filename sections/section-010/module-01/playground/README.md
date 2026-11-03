# API Server Security Boundaries: Playground

- **Slug:** ats-042-playground-010-01
- **Type:** Astrona playground, a clean environment with no task and no grading
- **Status:** UNTESTED. Checked only with `astrona validate`, `bash -n` and YAML parsing.

The playground starts the Starfleet workloads, a pipeline service account bound to cluster-admin and a binding that gives pod read access to unauthenticated users.

## Run it

```sh
astrona run -c .
astrona destroy ats-042-playground-010-01
```

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `bootstrap/prepare.sh` | Applies the manifests and waits for the workloads |
| `manifests/` | Starting objects |
| `docs/overview.md` | The only learner page |
