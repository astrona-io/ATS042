---
draft: true
exam_objectives:
  - Container Runtime
---
# Runtime Interfaces And Host Authority

Kubernetes needs software on each node that can pull images and manage containers. The container runtime provides that execution capability. The kubelet coordinates Pod execution and communicates with a runtime through the Container Runtime Interface (CRI), an interface contract for Kubernetes container management.

Containerd and CRI-O are examples of runtimes used with Kubernetes. The runtime manages images, container lifecycle and related operations. A lower-level runtime such as runc can create the operating system isolation and start a container process. Separating these layers explains why image management and process creation are related but not identical jobs.

The Open Container Initiative (OCI) defines specifications for container images, runtime behavior and image distribution. These standards help compatible tools exchange artifacts and execute containers. The CRI describes Kubernetes-to-runtime integration; OCI specifications describe other interoperability contracts. They are not interchangeable names for one application programming interface (API).

A developer can build an image with one tool and run it with another compatible runtime. Kubernetes does not require that the same build tool be installed on every worker node. Nodes need an appropriate runtime and access to the image, not the source repository and development build environment.

A runtime failure can prevent assigned Pods from starting even when the API server and scheduler are healthy. A build failure happens before a usable image exists. An image pull failure concerns artifact access or selection. Correctly identifying the layer avoids blaming every container problem on the Kubernetes control plane.

For a question about who starts the process, choose the node execution components. For a question about how the kubelet requests container operations, identify the CRI. For portable artifact formats, identify the relevant OCI specification.

## Following Runtime Operations On A Node

An assigned Pod tells the kubelet which containers should exist. The kubelet requests operations from the configured runtime through the CRI. The runtime obtains images, prepares container execution state and manages lifecycle operations. Lower-level components create namespaces, cgroups and the process according to the runtime's implementation.

A networking plugin can participate in preparing the Pod sandbox, while storage components provide mounted data. The runtime is essential to execution, but it does not independently own all placement, network policy or durable storage decisions. A runtime-ready node can still have an application blocked by an unavailable volume.

This division explains several symptoms. If the kubelet cannot communicate with its runtime, container creation can fail across workloads on that node. If one artifact reference is invalid, only workloads depending on it may fail. If an application starts and rejects its settings, execution worked well enough to reach application logic, so the next evidence belongs at that layer.

## Portable Artifacts And Interface Compatibility

An OCI-compatible image describes filesystem content and runtime configuration through a defined format. A build tool produces that artifact; a runtime consumes it. The CRI provides the kubelet's integration boundary to the runtime. A platform needs compatible components at both boundaries, not a claim that one standard covers every interaction.

Processor architecture remains part of compatibility. A portable format containing only an unsupported architecture variant cannot execute normally on the node merely because its metadata follows a standard. Operating system requirements and runtime capabilities also matter.

Avoid assuming Docker as a development tool must be the node runtime. Teams can build through one compatible toolchain and execute through containerd or CRI-O. The important reasoning is which artifact was produced, which interface the node uses and whether the execution platform supports the selected content.

## Common pitfalls

> [!WARNING]
> CRI is the kubelet's runtime integration interface. OCI specifications cover image, runtime and distribution interoperability; they do not replace that interface.
