# Green CI, Stale Deploy — Plain-English Project Walkthrough

## What this project is in one paragraph

A minimal, runnable repro of a real bug class: a size-only sync step lets a byte-length-identical content change ship as a silent stale deploy while every CI signal stays green.

## The simple analogy

Like a security guard who only checks if a box is the same size as yesterday's delivery, not what's
actually inside it - a completely different box that happens to weigh the same walks right past.

## What problem we are solving

"CI is green" and "the live site actually serves what I just built" are two different claims, and
most pipelines only ever check the first one. This repo makes that gap concrete and reproducible
in minutes, instead of asking a reader to trust a description of an incident they can't verify
themselves.

## What we have built so far

- Scaffolded 2026-07-22 — repo and vault control plane created.
- Same day: a tiny static site, a "deploy" script mirroring `aws s3 sync --size-only`'s real
  comparison logic, a content-hash verification script (the fix), and a test that runs both
  scenarios and asserts the bug reproduces AND the fix catches it - the same script CI runs on
  every push.
- Two review passes found and fixed 12 issues, including a bug in the first round's own fix
  (bash's own string-substitution shares one of sed's escaping gotchas) and a self-caught bug
  found only while manually re-verifying a later fix (an error-message pair swapped relative to
  which case actually fired - correct exit code, wrong message, a small real-world instance of
  this repo's own thesis).

## How the pieces fit together

`scripts/render.sh` builds a tiny page with a build-date footer. `scripts/sync-size-only.sh` is
the bug: it copies files only when their size differs from what's already deployed.
`scripts/verify-deploy.sh` is the fix: it compares content hashes instead. `tests/test-repro.sh`
runs both in sequence against a two-day scenario (a same-length date change on day two) and
asserts the bug shows up and the fix catches it - the whole thing has to stay true for the script
to exit 0, which is what keeps CI meaningfully green rather than just green.

## What is deliberately not automated yet

The verification script only checks that every file in the build artifact is correctly live - it
doesn't detect orphaned files still live but removed from the build. Disclosed as a known,
deliberate v1 scope limit in the README, matching the real `engine-gateway-lab` design this
generalizes from.

## How this could connect to the wider Hekton factory

This is a sanitized, standalone extraction of a real `engine-gateway-lab` finding - the
generalizable half of an internal incident, built specifically so a public essay can point at
something real instead of describing something private.

## Current confidence level

High — small, fully self-contained, and its central claim (the bug reproduces, the fix catches
it) is asserted by the test itself on every run, not just described in prose. Verified against
real CI on the actual public repo, not just locally.

## Open questions

- None blocking - the scope is deliberately narrow and complete for what it demonstrates.

## Next recommended session

Draft the Agentic Tekton essay this repo is the companion artefact for
(`content-packages/governance-that-survives-confidence/brief.md` in the sibling `agentic-tekton`
repo).
