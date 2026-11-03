---
estimated_duration: 35m
---

# Capstone: Lock Down Services In A Namespace

**UNTESTED:** this lab was not run on a cluster. It was checked only with `astrona validate`, `bash -n` and YAML parsing. Run `astrona test -c <lab>` before publishing.

Capstone for the kube-proxy section. In the namespace `lane`, two Services are NodePorts and one also sets an externalIP, and the service account `lane-ops` holds write rights on Services and endpoints in every namespace.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-060/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS042.git -c sections/section-060/capstone/labs/lab-01
astrona destroy ats-042-capstone-060
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-lane-services-clusterip.sh` | every Service in lane is ClusterIP without externalIPs or node ports |
| `validate-lane-services-have-endpoints.sh` | cargo and beacon each have a ready endpoint |
| `validate-lane-ops-scoped.sh` | lane-ops manages Services only in lane |
| `validate-lane-ops-no-endpoint-writes.sh` | lane-ops cannot write Endpoints or EndpointSlices |
| `validate-lane-admission-policy.sh` | lane rejects NodePort, LoadBalancer and externalIPs Services and accepts ClusterIP |
