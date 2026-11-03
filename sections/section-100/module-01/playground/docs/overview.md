# Overview: Client Credentials And Configuration (Playground)

This is a **playground**, not a lab. It starts a fresh cluster and waits. There is no task, no `astrona submit` and no pass or fail. Change things, break them, run `astrona destroy`, and start over.

## What is in the cluster

- A kind cluster running Kubernetes 1.35 with one node.
- The Starfleet workloads: `scout`, `probe` and `shuttle` in `starfleet`, and `drifter` in `outpost`.
- The service account `runner` and a Role `pod-reader` with a RoleBinding in `starfleet`.
- No certificate requests and no token Secrets at the start.

## Helpers

```sh
who_am_i() {
  kubectl --token="$1" auth whoami
}
```

Use `who_am_i TOKEN` to print the identity that a token carries. The commands that create certificates need `openssl` on your machine.

## Practice tasks

- Print the active context with `kubectl config view --minify` and find the server address and the masked certificate data.
- Create a demo kubeconfig with `insecure-skip-tls-verify` and read it back with and without `--raw`.
- Create a key and a certificate request for the subject `CN=crew` and `O=bridge`, submit it and read the subject back from the object before approving.
- Approve the request, read the certificate and check its subject and end date with `openssl x509`.
- Make a request as `crew` and read the `Forbidden` message. Then bind a Role to the user and repeat it.
- Create a token for `runner` with `kubectl create token`, call `auth whoami` with it and try a request that its role forbids.
- Create a legacy token Secret for `runner`, read the token, delete the Secret and confirm that the token no longer works.
