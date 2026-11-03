# Overview: Container Network Trust (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Change things, break them, run `astrona destroy`, and start over.

## What is in the cluster

- A kind cluster running Kubernetes 1.35 with Calico as the network plugin.
- The Starfleet workloads: `scout`, `probe` and `shuttle` in `starfleet`, and `drifter` in `outpost`.
- No NetworkPolicy objects at the start.

## Helpers

```sh
call() {
  kubectl -n "$1" exec "deploy/$2" -- curl -sS --max-time 3 -o /dev/null -w '%{http_code}\n' "$3"
}
```

Use `call NAMESPACE DEPLOYMENT URL`, for example `call starfleet shuttle http://probe.starfleet.svc/get`. A result of `200` means the request worked. A timeout means the packet was dropped.

## Practice tasks

- List the Pods with `kubectl get pods -A -o wide` and note the Pod IP addresses.
- Run `call starfleet shuttle http://probe.starfleet.svc/get` and `call outpost drifter http://probe.starfleet.svc/get`. Both succeed.
- Apply a default deny ingress policy in `starfleet` and repeat both requests.
- Add an allowance from `shuttle` to `probe` on container port 8080 and check that only `shuttle` can connect.
- Write an egress policy for `shuttle` that allows DNS and `probe` only, then check that `scout` is no longer reachable.
- Change the allowance to the Service port 80 and observe that it no longer matches.
