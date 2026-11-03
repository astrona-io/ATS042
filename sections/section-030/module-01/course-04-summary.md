---
draft: true
exam_objectives:
  - Scheduler
---
# Summary

The kube-scheduler selects a node for each pod that has none. It filters out nodes that cannot run the pod, scores the remaining nodes, picks the best and records the choice through a binding request to the API server. The kubelet then runs the pod. The scheduler does not start containers and does not enforce isolation after placement.

Placement rules become security rules only with controlled ownership. A nodeSelector or required node affinity limits which nodes a pod may use. A taint keeps pods away from a node unless they carry a matching toleration, but a toleration alone does not force a pod onto the node. If an untrusted identity can label or taint nodes, or can set a pod's `nodeName`, it can defeat the rule. Admission policy, RBAC on nodes and on `pods/binding`, and the NodeRestriction plugin close those paths.

Availability has its own controls. Resource requests larger than any node make pods Pending. Priority classes let important pods preempt less important ones, so who may use a priority class must be limited, and a ResourceQuota with a priority class scope does that. Topology spread constraints keep replicas on different nodes. The event `FailedScheduling` on a pod states the reason for a Pending pod.

Key facts:

- A running pod keeps running if the scheduler stops, but new pods stay Pending.
- Node labels, taints and the right to create bindings are part of the trust boundary.
- A Pending pod is a scheduling signal, not an application error.

<!-- astrona:playground:destroy -->
