---
draft: true
exam_objectives:
  - Client Security
---
# Summary

A kubeconfig file selects a server, a way to verify it and a credential, and merges with other files and flags. It grants nothing. The cluster entry decides whether the client verifies the server with a certificate authority, and skipping verification keeps the encryption but removes the proof of which machine answered. The credential in the user entry works for anyone who holds it, so files, command output with raw values and build logs are places where it leaks. An entry that runs a program makes a file from another source a way to run commands on the machine that uses it.

A client certificate maps its subject to an identity. The common name is the user and each organization entry is a group, and the API server trusts the subject that the authority signed. The certificate request object carries a request, a signer name, usages and a requested lifetime. A reviewer approves or denies it, and the signer writes the certificate into the status. The permissions to approve and to sign are powerful, because approving a request with a privileged group creates an administrator. The cluster keeps no revocation list, so the controls are a short lifetime, review at approval and removal of role bindings.

Service account tokens come in two kinds. Tokens from the token request API expire, can have an audience and can be bound to an object that ends them when it is deleted. Legacy token Secrets never expire and work until the Secret is removed. The right to create tokens for an account equals the permissions of the account. Automation should use one account per job, a Role in the namespaces it needs, a short lifetime and a credential that does not sit in a repository or a log.

When a credential leaks, remove the permissions first so that a copy is worthless, then remove the credential, then read the audit trail for what it did.

Key facts:

- A context changes the target, not the permissions.
- Group names in a certificate are trusted as signed.
- Signed certificates cannot be revoked.
- Legacy token Secrets never expire.

<!-- astrona:playground:destroy -->
