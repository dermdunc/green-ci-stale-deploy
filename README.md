# Green CI, Stale Deploy

**Classification:** factory-output · **Owner:** dermdunc · **Status:** experimental, v0

[![CI](https://github.com/dermdunc/green-ci-stale-deploy/actions/workflows/ci.yml/badge.svg)](https://github.com/dermdunc/green-ci-stale-deploy/actions/workflows/ci.yml)

> A minimal, runnable repro of a real bug class: a size-only sync step lets a byte-length-identical content change ship as a silent stale deploy while every CI signal stays green.

## The bug

A deploy pipeline that syncs a build to a static host by comparing file **size** instead of file
**content** will happily skip uploading a file whose content changed but whose byte length
happened not to. This is exactly what `aws s3 sync --size-only` does: it compares object sizes
only, never checksums, to save the cost of hashing every object on every deploy.

That's a reasonable trade-off almost all of the time. It fails silently the moment two versions of
a file are the same length, which is common for anything with a fixed-format timestamp: a build
date, a version string, a day-of-month. CI passes. The sync step reports success. The CDN
invalidation runs cleanly. Nothing anywhere goes red. The live site just keeps serving the old
bytes.

## Why CI doesn't catch it

Every step in a typical pipeline checks that *it* did its job, not that the *outcome* is correct:
the build step checks the build succeeded, the sync step checks the sync command exited zero, the
invalidation step checks the CDN accepted the request. None of them ever ask "does the live URL
now serve what I just built?" That's a different question, and it needs a different check.

## Reproduce it locally

```bash
git clone https://github.com/dermdunc/green-ci-stale-deploy.git
cd green-ci-stale-deploy
./tests/test-repro.sh
```

This renders a tiny page with a build-date footer, "deploys" it twice with a size-only sync
(`scripts/sync-size-only.sh`, the same comparison logic as `aws s3 sync --size-only`), and asserts
two things empirically, not by inspection:

1. **The bug is real.** Day two's date change ("16 July 2026" to "17 July 2026," same length)
   never uploads. The "live" copy still shows day one's date.
2. **The fix catches it.** `scripts/verify-deploy.sh` compares SHA-256 content hashes instead of
   sizes, and correctly fails, naming the stale file.

Both assertions have to hold for the script to exit 0. This is a characterization test, not a
demo, so it fails loudly if either the bug or the fix stops reproducing.

`.github/workflows/ci.yml` runs the same script on every push to `main` and every pull request. A
green check here means both
properties still hold, not that nothing bad happened.

## The fix

Compare content, not size. `scripts/verify-deploy.sh` hashes every file in the build artifact and
confirms its live counterpart matches, failing loudly on any mismatch. Same design pattern as a
real post-deploy verification step: after the sync, fetch what's actually live and confirm it
matches what you just built, instead of trusting the sync tool's own exit code.

Scope, disclosed rather than assumed: this checks that everything in the build artifact is
correctly live. It doesn't detect orphaned files still live but no longer in the build (a page you
deleted) - a known, deliberate v1 gap, the same one a real "artifact vs. live" check has to accept
before it also does a full-tree diff.

## What this is not

Not a full CI/CD reference architecture, and not tied to AWS specifically. `aws s3 sync
--size-only` is the concrete, real-world example, but the underlying failure (a change-detection
heuristic with a blind spot, trusted as if it were a correctness check) generalizes to any
sync/deploy tool that optimizes by skipping unchanged-looking files.

## Layout

```
site/index.html.tmpl        the page template, {{DATE}} is the only dynamic content
scripts/render.sh           renders the template with a given date string
scripts/lib.sh              portable size/hash helpers, shared by the two scripts below
scripts/sync-size-only.sh   the buggy sync (mirrors aws s3 sync --size-only)
scripts/verify-deploy.sh    the fix (content-hash comparison)
tests/test-repro.sh         runs the full scenario, asserts both properties
```

## Implementation Status

- Scaffolded and built 2026-07-22, repro, fix, and CI all live same day.

## Documentation Contract

Agents working here must inspect `.hekton/project.yaml` before structural changes, keep `docs/session-log.md` current, record meaningful design decisions in `docs/decisions.md`, and update `docs/next-actions.md` when the work queue changes.

Vault mutation policy: see `vault_mutation_allowed` in `.hekton/project.yaml` (authoritative; defaults to false at scaffold time). The repo-local `mind-palace/` folder is only a mirror draft; do not write to the live vault unless `.hekton/project.yaml` says mutation is allowed and it is explicitly authorised in-session.

## Key Docs

- [Session Log](docs/session-log.md)
- [Decisions](docs/decisions.md)
- [Risks](docs/risks.md)
- [Project Walkthrough](docs/project-walkthrough.md)
- [Next Actions](docs/next-actions.md)
- [Operating Model](docs/operating-model.md)
- [Human Understanding Check](docs/human-understanding-check.md)
- [Depth Decision](docs/depth-decision.md)
- [Retire / Promote Review](docs/retire-promote-review.md)
