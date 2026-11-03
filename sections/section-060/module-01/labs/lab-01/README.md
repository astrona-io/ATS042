---
estimated_duration: 25m
---

# Lab: Close Service Exposure And Endpoint Write Rights

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Graded lab for the kube-proxy module. A Service in `starfleet` is a NodePort with an externalIP, the service account `intern` can write Services and endpoints in every namespace, and the kube-proxy configuration exposes its metrics on every address.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-060/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-060/module-01/labs/lab-01
astrona destroy ats-042-lab-060-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-gateway-clusterip.sh` | gateway is a ClusterIP Service with no externalIPs and a ready endpoint |
| `validate-externalips-rejected.sh` | a Service with externalIPs is rejected in starfleet and a ClusterIP Service is accepted |
| `validate-intern-no-traffic-writes.sh` | intern cannot write Services, Endpoints or EndpointSlices but can read Services |
| `validate-proxy-metrics-local.sh` | kube-proxy metricsBindAddress is the loopback address and the file is otherwise kept |
