# Session Log: Green CI, Stale Deploy

## 2026-07-22 - Initial scaffold

Project scaffolded as **factory-output**. Purpose: A minimal, runnable repro of a real bug class: a size-only sync step lets a byte-length-identical content change ship as a silent stale deploy while every CI signal stays green.

### Decisions Made

- Classification: factory-output
- Owner: dermdunc
- Vault mutation: not allowed by default (see `vault_mutation_allowed` in `.hekton/project.yaml` for the authoritative, current value)
- Promotion target: none

### Next Actions

- Define brief and first phase plan
- Add first implementation
- Record initial decisions
