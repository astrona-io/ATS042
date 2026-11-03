---
draft: true
exam_objectives:
  - KubeProxy
---
# KubeProxy And Service Forwarding

A Service address belongs to no interface. Kube-proxy watches Services and EndpointSlices and writes rules in each node so that a connection to the address reaches a ready pod. This module explains how those rules are built, which fields and rights change where traffic goes, and how the proxy is configured, protected and diagnosed.

Keep one sentence in mind: whoever writes a Service or an EndpointSlice decides where traffic goes.

## Learning objectives

After this module you can:

- Explain what kube-proxy reads, what it changes on the node and why traffic keeps flowing when it stops.
- Describe the credentials and host access of the kube-proxy DaemonSet.
- Compare the Service types and the traffic policies that change exposure.
- Explain why externalIPs and write access to EndpointSlices let a user capture traffic.
- Write an admission policy that rejects risky Service fields.
- Read the kube-proxy configuration and name the settings that matter for security.
- Diagnose a Service that does not answer, from selector to node rules.

## What the parts cover

1. **Protecting The Service Traffic Path**: explains how kube-proxy programs node rules from Services and EndpointSlices, and what access it holds.
2. **Service Exposure And Endpoint Trust**: explains Service types, traffic policies, externalIPs and the trust placed in endpoint data.
3. **Proxy Configuration, Health And Failure**: explains the proxy configuration, its ports, its failure modes and a diagnosis path.

## Before you start

You need Kubernetes basics: namespaces, Deployments, Services, pods and the commands `kubectl get`, `kubectl apply` and `kubectl describe`. The playground is a kind cluster running Kubernetes 1.35. `kubectl` already points at it as the cluster administrator.

The playground has the Starfleet workloads and a service account `intern` that can write Services, Endpoints and EndpointSlices in every namespace. You can read the kube-proxy pods and configuration, compare a Service with its EndpointSlice and validate a Service that sets externalIPs.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
