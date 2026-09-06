# Retire / Promote Review: Green CI, Stale Deploy

Review default: factory output does not automatically promote to platform, but learnings may become templates or platform backlog.

**Last updated:** 2026-09-06 (first real review since scaffold; part of a factory-wide dormant-project sweep).

## Retire / Promote Review

### Current state
Archived, 2026-09-06.

### Evidence gathered
- Built 2026-07-22 per `agentic-tekton`'s spec: a minimal, runnable repro of a real bug class (size-only sync lets a byte-identical content change ship as a silent stale deploy while CI stays green), plus the fix (content-hash comparison) and a test asserting both properties.
- Doubt-driven-development pass (Explore agent) found and fixed 8 issues; cross-model review (Codex, gpt-5.5) found and fixed 4 more, including one bug in the first round's own fix — both rounds recorded in `docs/decisions.md`.
- Blog post published in `agentic-tekton`'s post-backlog, marked shipped.
- No commits since 2026-07-26 (the shared 2026-07-31 commit across several factory-output repos was housekeeping, not project activity).
- Grepped the rest of the monorepo: no other project's `depends_on`/`enables`/`consumes` or docs reference this repo.

### Value score
- Reuse: Low. No other project imports or runs this repro; it exists to demonstrate a bug class, not as a library.
- Clarity: High. The design choice (CI stays green while still proving something real) is documented and the test does exactly what the README claims.
- Automation: Medium. CI runs the repro on every push/PR; no scheduled or hooked usage beyond that.
- Decision quality: High. Two independent review rounds, including a self-caught bug in the first round's own fix — recorded plainly rather than smoothed over.
- Strategic leverage: Low. A finished demonstration piece, not infrastructure anything else builds on.

### Cognitive load score
Low. Small, self-contained repro; no dependents to break.

### Recommendation
Retire (archive).

### Rationale
The deliverable shipped (working repro + fix + test, green CI, published blog post), the intended purpose is complete, and a full-monorepo grep found zero inbound references from any other lab, platform, or factory-output project. Finished one-off experiment, not an abandoned one.

### Next action
1. Archive banner added to `README.md` (this session).
2. `.hekton/project.yaml` flipped to `status: archived` / `lifecycle_stage: archived` (this session).
3. GitHub repo archived: `gh repo archive dermdunc/green-ci-stale-deploy` (this session, per `promotion-rules.md`'s archive-immediately rule).
