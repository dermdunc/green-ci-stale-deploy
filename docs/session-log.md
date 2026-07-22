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

## 2026-07-22 - Build: the repro, the fix, two-cycle doubt-driven review

### What Changed

Built per `agentic-tekton`'s existing spec: `site/index.html.tmpl`, `scripts/render.sh`,
`scripts/lib.sh`, `scripts/sync-size-only.sh` (the bug), `scripts/verify-deploy.sh` (the fix),
`tests/test-repro.sh` (asserts both empirically), `.github/workflows/ci.yml`, `README.md`. Two
doubt-driven-development cycles (single-model `Explore`, then Codex cross-model) found and fixed
12 issues total, including a bug in the first round's own fix (bash's `${var//pattern/replacement}`
turned out to share sed's `&`-is-special-in-the-replacement behavior) and a self-caught bug found
only while manually verifying a fix (an error-message pair swapped relative to which case actually
matched - correct exit code, wrong message). Full detail in `docs/decisions.md`.

### Why

Unblocks `content-packages/governance-that-survives-confidence/brief.md` on the sibling
`agentic-tekton` repo - that essay was explicitly blocked on this artefact existing.

### Validation

`./tests/test-repro.sh` re-run after every fix; final state re-verified against every edge case
raised by either review round (trailing slashes, sed-hostile date strings, missing/empty/nested
directories) before treating this as done.

### Next Actions

- Commit, merge to `main`, push; confirm GitHub Actions actually goes green on the real repo.
- Update `agentic-tekton`'s `content-packages/governance-that-survives-confidence/brief.md` and
  `docs/post-backlog.md` with this repo's real URL, unblocking that post.

### Mind-palace updated

Not this session - repo-local mirror only, `vault_mutation_allowed: false`.
