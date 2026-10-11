---
draft: true
exam_objectives:
  - Scheduler
---
# Summary

The scheduler assigns workloads using resource and placement rules. Its identity and configuration affect the integrity and availability of those decisions. Metadata used for security-significant selection needs trusted ownership.

Node separation contributes to a broader trust design. Admission, runtime privileges, networking and administrative boundaries still determine what a placed workload can do. Diagnose scheduler-wide failure separately from unsuitable requirements on one workload.
