# Container Network Trust: Playground

- **Slug:** ats-042-playground-090-01
- **Type:** Astrona playground, a clean environment with no task and no grading
- **Status:** UNTESTED. Checked only with `astrona validate`, `bash -n` and YAML parsing.

The playground starts a Calico cluster with the Starfleet workloads and no network policies.

## Run it

```sh
astrona run -c .
astrona destroy ats-042-playground-090-01
```

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `bootstrap/prepare.sh` | Applies the manifests and waits for the workloads |
| `manifests/` | Starting objects |
| `docs/overview.md` | The only learner page |
