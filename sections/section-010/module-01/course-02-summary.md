---
draft: true
exam_objectives:
  - API Server
---
# Summary

The API server checks caller identity, requested permission and relevant admission policy before storing a change. Transport verification and endpoint restrictions protect the access path while narrow grants limit accepted authority.

Datastore access, admission dependencies and audit retention have their own trust and availability requirements. A compromised authorized credential can misuse legitimate API operations, so detection and recovery must account for the actions its grants permit.
