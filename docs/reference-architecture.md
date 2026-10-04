# CSPM Reference Architecture

## Objective

A CSPM system should do more than list misconfigurations. It should help a security team answer:

- What is exposed?
- What identity can reach it?
- What is the likely impact?
- Which control failed?
- What should be fixed first?
- How do we prove the fix?

## Operating model

```mermaid
flowchart TD
    S[Cloud Sources] --> N[Normalize Assets]
    N --> G[Build Exposure + Identity Context]
    G --> C[Evaluate Controls]
    C --> Q[Score Risk]
    Q --> T[Triage]
    T -->|Remediate| R[Remediation]
    T -->|Accept temporarily| X[Time-bound Exception]
    R --> V[Re-evaluate]
    X --> V
    V --> E[Evidence / Audit]
```

## Prioritization dimensions

A useful score combines:

- baseline severity
- internet exposure
- data sensitivity
- privilege level
- exploitability
- compensating controls

The sample implementation intentionally stays small so the decision model is easy to inspect.
