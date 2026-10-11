# Curriculum Coverage

Exam: Kubernetes and Cloud Native Associate (KCSA). Domain: Kubernetes Cluster Component Security (22%).

Verified against the [official objectives](https://training.linuxfoundation.org/certification/kubernetes-and-cloud-native-security-associate-kcsa/) on 2026-10-11. Module titles and questions are original teaching material, not official exam questions.

| Section | Official objective | Modules | Status |
| --- | --- | --- | --- |
| 010 | API Server | 1 | Written; review pending |
| 020 | Controller Manager | 1 | Written; review pending |
| 030 | Scheduler | 1 | Written; review pending |
| 040 | Kubelet | 1 | Written; review pending |
| 050 | Container Runtime | 1 | Written; review pending |
| 060 | KubeProxy | 1 | Written; review pending |
| 070 | Pod | 1 | Written; review pending |
| 080 | Etcd | 1 | Written; review pending |
| 090 | Container Networking | 1 | Written; review pending |
| 100 | Client Security | 1 | Written; review pending |
| 110 | Storage | 1 | Written; review pending |

| Section / module | Module | Teaching lessons | Measurable outcomes |
| --- | --- | --- | --- |
| 010 / 01 | API Server Security Boundaries | 1 | Explain the API server's identity, permission and admission checks.; Relate API transport protection to authenticated peer identity.; Identify risks from excessive API exposure and powerful credentials.; Distinguish API audit evidence from application request logs. |
| 020 / 01 | Controller Manager Authority | 1 | Explain controller reconciliation and API permissions.; Identify consequences of a compromised controller identity.; Relate controller availability to workload recovery.; Distinguish Kubernetes controller behavior from application data repair. |
| 030 / 01 | Scheduler Integrity And Availability | 1 | Explain what the scheduler decides and what it cannot execute.; Relate node labels and placement rules to security assumptions.; Identify the impact of scheduler identity or configuration compromise.; Distinguish placement controls from complete tenant isolation. |
| 040 / 01 | Kubelet And Node Access | 1 | Explain the kubelet's authority over assigned Pods.; Distinguish API permissions from direct node-agent access.; Identify sensitive data available through node and workload operations.; Relate node credentials and endpoint protection to cluster trust. |
| 050 / 01 | Container Runtime Protection | 2 | Explain the runtime's execution authority and CRI boundary.; Identify risks from exposed runtime sockets and privileged containers.; Relate image selection to execution trust.; Compare runtime isolation with application authorization. |
| 060 / 01 | KubeProxy And Service Forwarding | 1 | Explain kube-proxy's Service forwarding responsibility.; Distinguish forwarding from authentication and encryption.; Identify risks from compromised forwarding configuration.; Relate alternative implementations to the same security contract. |
| 070 / 01 | Pod Execution And Credential Boundaries | 1 | Explain shared resources and trust within a multi-container Pod.; Identify unnecessary host access and API credential exposure.; Relate security context and admission to Pod execution.; Describe replacement without assuming restored trust. |
| 080 / 01 | Etcd And Stored Cluster Data | 1 | Explain why direct etcd access is a powerful security boundary.; Distinguish transport encryption, storage encryption and authorization.; Relate quorum, backups and access control to recovery.; Identify sensitive information in datastore snapshots. |
| 090 / 01 | Container Network Trust | 2 | Identify the network implementation's authority and dependencies.; Distinguish Service forwarding from connection policy enforcement.; Relate node access, plaintext traffic and trusted peers.; Explain how network segmentation limits compromise paths. |
| 100 / 01 | Client Credentials And Configuration | 1 | Explain kubeconfig credential and context risks.; Relate transport verification to the intended cluster identity.; Identify sensitive data in local files and automation logs.; Compare routine client authority with administrative authority. |
| 110 / 01 | Storage Access And Data Security | 1 | Distinguish API storage resources from backend data permissions.; Explain confidentiality risks in volume mounts and snapshots.; Relate encryption, reclaim policy and recovery to data protection.; Identify node and driver trust in mounted storage. |

Every section begins with an introduction. Every module ends with a summary before the next module. YAML checkpoint banks follow selected section summaries; a domain review bank closes the course. They are indexed separately for future application integration.

This course has no labs or playgrounds, as requested by the maintainer. All material is readable without a cluster. Technical content remains draft until review; no runtime execution or lab validation is claimed.
