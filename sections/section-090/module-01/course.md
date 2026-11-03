---
draft: true
exam_objectives:
  - Container Networking
---
# Container Network Trust

Pods receive addresses and can reach each other across nodes and namespaces. This module explains the network model and the part that the network plugin plays, shows that the default is open, and teaches how to write NetworkPolicy for ingress and egress, including DNS, with real requests as proof. It also lists what policy does not cover.

Keep one sentence in mind: a pod is reachable from everywhere until a policy isolates it, and a policy only allows what it names.

## Learning objectives

After this module you can:

- State the rules of the Kubernetes network model.
- Explain what a CNI plugin does and why policy needs a plugin that enforces it.
- Show that the default cluster network allows traffic between namespaces.
- Write a default deny policy and an allowance with a precise source and port.
- Explain how policies combine and why source and destination must both allow a connection.
- Distinguish one peer with two selectors from two peers.
- Write an egress policy that keeps DNS working.
- List traffic that NetworkPolicy does not control.

## What the parts cover

1. **Pod Networks And Policy Boundaries**: explains the network model, the plugin and why the default is open.
2. **Allowed Connections And Enforcement**: explains isolation, default deny, allowances and how selectors combine.
3. **Egress, DNS And Traffic Outside Policy**: explains egress policy, DNS, address ranges and traffic that policy does not cover.

## Before you start

You need Kubernetes basics: namespaces, Deployments, Services, pods and the commands `kubectl get`, `kubectl apply` and `kubectl describe`. The playground is a kind cluster running Kubernetes 1.35. `kubectl` already points at it as the cluster administrator.

The playground runs Calico, which enforces NetworkPolicy, with the Starfleet workloads. `shuttle` and `drifter` have `curl`, so you can send real requests to `probe` and `scout` before and after you apply policies.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
