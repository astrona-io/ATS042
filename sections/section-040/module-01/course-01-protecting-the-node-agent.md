---
draft: true
exam_objectives:
  - Kubelet
---
# Protecting The Node Agent

The kubelet makes assigned Pods run on a node and reports their state. It coordinates runtime, storage and preparation operations, and it can access information needed by the workloads it manages. This makes the node agent and its credentials a security boundary with direct consequences for container execution.

## Node Identity And application programming interface (API) Access

A node uses a configured identity to communicate with the API server. The control plane needs to recognize legitimate nodes while limiting what each node can do. The Node authorizer and NodeRestriction admission plugin can contribute to constraining node actions when used correctly. Their protection depends on the expected node identity format and effective configuration.

A worker should not be assumed to need unrestricted access to every Secret or workload in the cluster. The information required for assigned Pods differs from general administrative authority. Protect node certificates and bootstrap credentials because someone obtaining them can attempt to act under the corresponding identity.

Node admission and bootstrap also require a trusted process. A machine joining a sensitive cluster must be the intended machine with an approved configuration. Automatically trusting arbitrary machines or approval requests weakens the cluster's infrastructure boundary.

## Direct Kubelet Endpoints

The kubelet can expose operations and diagnostics through its own endpoint. Direct access is a different path from an ordinary application request or a user's namespace-scoped API call. Authentication, authorization and network restriction must protect that path. Anonymous or broadly trusted access can expose sensitive workload information or execution capabilities depending on the endpoint and configuration.

Operations involving logs, process execution or port forwarding deserve careful permission analysis. They can reveal application data or reach a process under circumstances different from its normal public API. A user restricted from reading a Secret object may still obtain sensitive values through another overly broad diagnostic path.

Protect serving certificates and verify the peer identity when clients communicate with the node agent. A secure channel to the wrong endpoint does not establish trusted node management. Avoid treating disabled verification as a routine solution to certificate errors.

## Host Access And Workload Data

A node administrator or attacker with host-level authority can inspect container files, mounted data and process state according to the host environment. Pod security relies on that host being trusted. A namespace boundary cannot fully protect a workload from an administrator controlling its kernel and runtime.

The kubelet also needs resources to operate. Severe disk or memory pressure can interfere with management and trigger evictions. Workload limits and host resource management reduce some availability risks, while replacement still requires suitable capacity elsewhere.

## A Node-Agent Exposure Scenario

Suppose an application cannot call the API with its own token, but it can reach an inadequately protected node-agent endpoint. The missing API grant is not enough to establish safety. The direct endpoint creates another route whose allowed operations must be evaluated.

A defensive review narrows network access, configures trusted identities and appropriate authorization, protects node credentials and checks diagnostic permissions. If compromise occurred, inspect both node-local data and cluster actions possible through the exposed identities. Restoring one Pod does not by itself restore trust in the node that runs it.

## Common pitfalls

> [!WARNING]
> Direct node-agent access is a separate security path. A namespace-scoped API role does not automatically limit every kubelet endpoint or protect data from host-level compromise.
