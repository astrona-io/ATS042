---
draft: true
exam_objectives:
  - KubeProxy
---
# Summary

A Service address is virtual. Kube-proxy runs on each node, watches Services and EndpointSlices through the API server and writes rules into the kernel with iptables, IPVS or nftables. A connection to a Service address is rewritten to the address of one ready pod. The rules exist on every node, so traffic does not pass a central balancer, and when kube-proxy stops the existing rules keep forwarding while new changes are not applied.

Kube-proxy holds two powers. Its service account is bound to the node-proxier role, which reads Services, EndpointSlices and nodes. Its pod runs with host networking and a privileged container, so control of the DaemonSet is root access on every node. Kube-proxy does not enforce NetworkPolicy and does not authenticate traffic.

Service fields change who can send traffic. A NodePort opens a port on every node, a LoadBalancer extends that outward, and externalIPs lets the Service accept traffic for any address with no check, which can capture traffic meant for others. The traffic policies Local and Cluster decide whether traffic stays on the node and whether the client address is kept. Anyone who writes Services or EndpointSlices chooses where traffic goes, so write rights on them belong to controllers and trusted deployers, and an admission policy can reject externalIPs.

The configuration of kube-proxy is a ConfigMap in kube-system. Its metrics address should stay on the loopback interface and its health port should reach only the systems that need it. A change to the ConfigMap or the DaemonSet affects every node when the pods restart. To diagnose a Service, check the selector and the EndpointSlice, then readiness, then the kube-proxy pod on the client's node and its logs.

Key facts:

- Rules are programmed by kube-proxy and executed by the kernel.
- The node-proxier role is narrow, but the kube-proxy pod itself is privileged.
- externalIPs is not verified by Kubernetes.
- Write access to EndpointSlices redirects traffic.

<!-- astrona:playground:destroy -->
