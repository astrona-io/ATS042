# Question

Solve this question on: `terminal`

Two certificate requests are waiting for a decision: `ensign` and `intruder`. Both use the signer `kubernetes.io/kube-apiserver-client`. The service account `courier` in the namespace `dock` has a legacy token Secret and a ClusterRoleBinding to `cluster-admin`. A kubeconfig for a deploy job sits in the ConfigMap `deploy-kubeconfig` in `dock`. Do not delete the namespace or the service account.

1. Review the two requests. Approve the one that asks for a normal user, and deny the one that asks for a group with full cluster rights. The approved request must have a signed certificate.

2. The user `ensign` must read pods in `dock` (`get`, `list` and `watch`) and do nothing else. Use a Role and a RoleBinding in `dock`.

3. `courier` must read pods in `dock` and have no other rights. Remove its legacy token Secret and its cluster-admin binding, and give it a Role in `dock` that allows `get`, `list` and `watch` on pods.

4. Move the kubeconfig into a Secret named `deploy-kubeconfig` with the key `config`. The new file must verify the server with the cluster certificate authority from the ConfigMap `kube-root-ca.crt`, must not skip verification, must not embed a token, and must read the token from a `tokenFile`. Delete the old ConfigMap.

`kubectl` points at the cluster as the cluster administrator.
