---
draft: true
exam_objectives:
  - Pod
---
# Summary

Containers in a pod share one network namespace, so a listener on the loopback address is reachable by every container in the pod, and a shared volume is writable by every container that mounts it. Filesystems and process lists are separate unless the specification shares them. The pod uses one service account for all of its containers.

Some pod settings remove isolation: a privileged container, host network, host process or host IPC namespaces, host path volumes, added capabilities and permitted privilege escalation. A hardened container runs as a non-root user, drops all capabilities, forbids privilege escalation and uses the runtime default seccomp profile. Pod Security Admission reads labels on a namespace and rejects new pods that break the chosen standard. It checks the declared specification only. Running pods are not stopped, and the label does not affect credentials.

A pod receives a bound, expiring service account token through a projected volume. The token is tied to the pod, has an audience and stops working when the pod is deleted. The field automountServiceAccountToken set to false on the service account or the pod removes the volume, and the pod field wins. A workload that calls an external service can use a projected token with its own audience and a short lifetime. A token has the rights of its service account, so rights on Secrets and the right to create pods deserve the same care as the token itself.

Interactive access is a set of separate permissions: exec and port forwarding need create on subresources of pods, and ephemeral containers need update or patch. A command started this way runs with the token and mounts of the pod. Deleting a pod is not recovery, because the controller recreates it from the same template. Recovery contains the damage, finds the entry, revokes exposed credentials, restores trusted inputs in their source and replaces the pods.

Key facts:

- Pod Security Admission checks the specification, not behaviour.
- A bound token expires and ends with its pod.
- Exec, attach and ephemeral containers are separate subresource rights.
- A new pod from an unchanged template repeats the compromise.

<!-- astrona:playground:destroy -->
