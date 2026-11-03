# Overview: Pod Execution And Credential Boundaries (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Change things, break them, run `astrona destroy`, and start over.

## What is in the cluster

- A kind cluster running Kubernetes 1.35 with one node.
- The Starfleet workloads: `scout`, `probe` and `shuttle` in `starfleet`, and `drifter` in `outpost`.
- The service account `crew`, a Role `crew-ops` that grants Secret reads, `pods/exec` and `pods/ephemeralcontainers`, and a Secret `warp-key`.

## Helpers

```sh
can_crew() {
  kubectl auth can-i "$@" -n starfleet --as=system:serviceaccount:starfleet:crew
}
```

Use `can_crew VERB RESOURCE`, for example `can_crew create pods/exec`.

## Practice tasks

- List the files in `/var/run/secrets/kubernetes.io/serviceaccount` inside the `shuttle` pod with `kubectl -n starfleet exec deploy/shuttle -- ls /var/run/secrets/kubernetes.io/serviceaccount`.
- Read the volumes of a `scout` pod with `kubectl -n starfleet get pod -l app=scout -o jsonpath='{.items[*].spec.volumes[*].name}'` and find the `kube-api-access` volume.
- Run `can_crew create pods/exec` and `can_crew get secrets`, then replace the Role `crew-ops` with one that only reads pods and logs.
- Label `starfleet` with `pod-security.kubernetes.io/enforce=baseline`, then run `kubectl apply --dry-run=server` on a pod with `privileged: true` and read the message.
- Set `automountServiceAccountToken: false` on the service account `shuttle`, restart the Deployment and confirm the token directory is gone.
- Request a token with `kubectl create token crew -n starfleet --duration 10m` and note that it expires on its own.
