# Question

Solve this question on: `terminal`

The namespace `ledger` holds the claim `records`. The Deployment `collector` writes to it and must keep doing so. The Deployment `reporter` only reads it. The Deployment `inspector` is a helper that does not need the data. The service account `clerk` is meant to look at claims. Do not delete the claim or the Deployments, and do not change `collector`.

1. `inspector` must not mount the claim `records` at all.

2. `reporter` must keep mounting `records` and mount it read-only. Its volume mount must have `readOnly: true`.

3. The PersistentVolume behind `records` must keep its data when the claim is deleted. Change its reclaim policy to `Retain`.

4. `clerk` must read claims in `ledger` (`get` and `list` on `persistentvolumeclaims`) and must not be able to create pods or Deployments there.

The Deployments must stay ready. `kubectl` points at the cluster as the cluster administrator.
