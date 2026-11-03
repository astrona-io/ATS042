---
draft: true
exam_objectives:
  - Container Networking
---
# Summary

The Kubernetes network model gives every pod its own address and lets every pod reach every other pod without translation. It describes connectivity, not security. Namespaces do not separate traffic, so a pod in one namespace can call a pod in another until a policy says otherwise. A CNI plugin sets up pod networking, and only some plugins enforce NetworkPolicy. The API server accepts a policy object whatever plugin is installed, so a plugin that ignores policy leaves pods open without an error.

A pod is open in a direction until a policy selects it for that direction. After that, only traffic that a policy allows is permitted, and the allowed set is the union of the rules of all policies that select the pod. A default deny policy selects every pod with an empty selector and lists a direction without rules. When both source and destination are isolated, the source needs an egress rule and the destination needs an ingress rule. Policy ports are container ports, because the rewrite from a Service address happens before the policy is checked.

The structure of a peer list changes the meaning. One peer with a namespace selector and a pod selector requires both. Two peers are alternatives, and the namespace selector alone allows every pod in the namespace. Egress policy limits where a taken-over pod can send traffic, and it needs an explicit rule for DNS, or every name lookup fails. An address range is for destinations outside the cluster.

Policy works on addresses, ports and protocols. It does not decide by HTTP path or identity, it does not encrypt traffic, and its effect on host network pods and node traffic depends on the plugin. A dropped packet shows as a timeout. Test every rule with a request that must work and one that must fail.

Key facts:

- The default network is open and namespaces are not boundaries.
- Policies only add allowed traffic.
- Policy ports are container ports.
- Egress rules need a DNS allowance.

<!-- astrona:playground:destroy -->
