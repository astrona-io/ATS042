---
draft: true
exam_objectives:
  - KubeProxy
---
# Protecting The Service Traffic Path

Kube-proxy is a node component used in many Kubernetes clusters to implement Service forwarding. It observes relevant application programming interface (API) state and configures forwarding behavior through the supported node networking mechanism. Other network implementations can provide this function instead, so the required security contract is broader than one binary name.

## Forwarding And Endpoint State

A client connects to a Service address and port. The forwarding implementation selects or reaches an eligible backend according to its design. Labels, EndpointSlices, readiness and port mapping influence the usable destination. The scheduler does not relay the packet, and the API server does not become the application's traffic proxy merely because it stores those resources.

The implementation needs a trusted view of Service and endpoint state. Its identity and API grants should support its role without unnecessary management authority. A credential or process compromise can have consequences through the component's permissions and node access.

Node-level forwarding often requires privileged interaction with networking facilities. Protecting that process and its configuration therefore matters to traffic integrity. A component used for routine networking is still part of the trusted path between applications.

## What Forwarding Does Not Provide

Reaching a backend does not authenticate the caller to the application. Ordinary Service forwarding does not automatically encrypt traffic or authorize an HTTP operation. A request can arrive successfully and still need transport identity, user credentials and data-specific checks.

Similarly, forwarding does not prove that the process at the destination is the intended application. Artifact verification, workload identity and routing configuration contribute to that trust. A malicious endpoint or changed selector can redirect clients toward an unintended process if the surrounding authority permits it.

NetworkPolicy can restrict supported connections through an enforcing implementation. It is a distinct mechanism from Service forwarding, even when one product implements both. Evaluate each requirement explicitly rather than assume all traffic passing through a Service has the same security properties.

## Exposure And Node Access

A NodePort can provide an entry path through node addresses. Infrastructure routing and firewall rules determine which callers can reach it. Source handling and forwarding behavior depend on relevant Service settings and implementation. Avoid inferring a caller's trusted identity solely from an address when intermediaries can alter the observed path.

A compromised node can affect local forwarding and observe plaintext accessible there according to the environment. Transport encryption can protect defined hops, but it depends on correct peer verification and where termination occurs. A stable Service address is not a confidentiality guarantee.

## A Misrouting Scenario

Suppose `probe` suddenly receives requests at a different workload. First compare the Service selector, endpoint records, route and actual backend identities. A malicious configuration change can misuse legitimate APIs; a forwarding fault can create a different symptom. Audit and node evidence help separate those explanations.

Recovery restores trusted configuration and affected node components, then verifies requests from the original callers. If traffic or credentials were exposed, the response must consider that data consequence as well as restoring connectivity. Correct packet delivery is only one property of secure service communication.

## Common pitfalls

> [!WARNING]
> Service forwarding does not automatically authenticate, authorize or encrypt application requests. Protect endpoint configuration and privileged node networking as separate trust boundaries.
