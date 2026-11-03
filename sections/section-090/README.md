---
draft: true
exam_objectives:
  - Container Networking
---
# Container Network Trust

The default Kubernetes network lets every pod reach every other pod. NetworkPolicy changes that, but only when the network plugin enforces it and only for the traffic it describes.

## Learning outcomes

- State the rules of the Kubernetes network model.
- Explain what a CNI plugin does and why policy needs a plugin that enforces it.
- Show that the default cluster network allows traffic between namespaces.
- Write a default deny policy and an allowance with a precise source and port.
- Explain how policies combine and why source and destination must both allow a connection.
- Distinguish one peer with two selectors from two peers.
- Write an egress policy that keeps DNS working.
- List traffic that NetworkPolicy does not control.

## What is in this section

The section has one module, Container Network Trust. It has 3 reading parts, a summary and a playground: a Calico cluster to send real requests between pods and test NetworkPolicy. A graded lab follows the reading part it practises. A capstone lab closes the section with a new scenario, and a knowledge check of ten questions follows the capstone.
