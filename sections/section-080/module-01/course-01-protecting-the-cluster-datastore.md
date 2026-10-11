---
draft: true
exam_objectives:
  - Etcd
---
# Protecting The Cluster Datastore

Etcd stores Kubernetes cluster records, including resource configuration and relevant sensitive data. Ordinary clients reach those records through application programming interface (API) server checks. Direct datastore access creates a different path that can bypass the normal resource-level authentication, authorization and admission contract.

## Restricting Datastore Access

Limit the network and identities permitted to reach etcd to the intended control plane components and controlled operators. Protect the credentials and host files used for that connection. An internal address is not sufficient protection if untrusted workloads or broad infrastructure identities can reach it.

Transport Layer Security (TLS) protects communication and can authenticate permitted peers when configured correctly. Peer trust and client trust should follow the actual component roles. A valid encrypted connection to a powerful storage interface is still dangerous when granted to an inappropriate caller.

The API server's role-based access control (RBAC) decision does not constrain a client that obtains direct datastore authority outside that path. This is why a workload restricted from reading Secret objects should not also receive datastore credentials through host files or diagnostics. Security analysis must include alternate routes to the same data.

## Sensitive Records And At-Rest Protection

Secrets and other records can contain credentials or confidential configuration. Kubernetes encryption-at-rest configuration can protect selected stored resource data according to its supported design. It is separate from network encryption and from the access rules applied by the API server.

An authorized API reader can receive plaintext even when stored records are encrypted. Encryption keys need protection, rotation and recovery handling. A key exposed alongside the encrypted data weakens the intended confidentiality boundary. A lost key can also prevent legitimate recovery.

Snapshots and backups need the same sensitivity analysis as the live datastore. They may retain old credentials or resource versions after the current cluster rotates them. Backup readers, storage locations and retention policies are therefore security-relevant, not only operational details.

## Availability And Quorum

Etcd consensus needs a majority of its configured voting members for normal progress. A three-member arrangement normally tolerates one member loss. Placing members across useful failure domains improves resilience, but access and certificate configuration must remain consistent with the trusted membership.

Replication supports continued operation through selected failures. It can also replicate unwanted changes. A backup supports historical recovery when its state is valid and the restoration procedure works. These are different protections with different evidence.

## A Datastore Exposure Scenario

Suppose an old snapshot is copied into a broadly readable storage location. The live API may still have narrow permissions, but the snapshot creates an independent disclosure route. Investigate what data it contains, who could read it and whether credentials remain valid. Rotating current values may be necessary, while deleting the copy does not undo past disclosure.

Recovery also needs to distinguish cluster records from application data. An etcd snapshot does not automatically contain every database or persistent volume used by applications. Restoring control plane configuration can leave application storage requiring its own consistent recovery procedure.

A secure datastore design protects direct access, encrypted boundaries, backup material and the identities needed for restoration. Each should be scoped and verified independently of ordinary workload permissions.

## Common pitfalls

> [!WARNING]
> Direct datastore access can bypass normal API resource checks. Snapshots are sensitive, and an etcd backup does not automatically restore every application's external data.
