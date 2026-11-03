# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You can scope RBAC, test rights as a user and a group with `kubectl auth can-i --as --as-group` and edit pod volumes.

The lab starts a kind cluster (Kubernetes 1.35) with the Starfleet workloads where the task needs them. The commands to start and submit the lab are in the task and solution pages.
