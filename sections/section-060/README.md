---
draft: true
exam_objectives:
  - KubeProxy
---
# KubeProxy

Kube-proxy runs on every node and turns Services and EndpointSlices into packet rules. The objects that define those rules, and the settings of kube-proxy itself, decide who can send traffic to which pods and who can redirect it.

## Learning outcomes

- Explain what kube-proxy reads, what it changes on the node and why traffic keeps flowing when it stops.
- Describe the credentials and host access of the kube-proxy DaemonSet.
- Compare the Service types and the traffic policies that change exposure.
- Explain why externalIPs and write access to EndpointSlices let a user capture traffic.
- Write an admission policy that rejects risky Service fields.
- Read the kube-proxy configuration and name the settings that matter for security.
- Diagnose a Service that does not answer, from selector to node rules.

## What is in this section

The section has one module, KubeProxy And Service Forwarding. It has 3 reading parts, a summary and a playground: a cluster to inspect kube-proxy, its configuration and Service rights, and to test an admission policy for Services. A graded lab follows the reading part it practises. A capstone lab closes the section with a new scenario, and a knowledge check of ten questions follows the capstone.
