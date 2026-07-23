# Brief: Green CI, Stale Deploy

> A minimal, runnable repro of a real bug class: a size-only sync step lets a byte-length-identical content change ship as a silent stale deploy while every CI signal stays green.

## Problem

`engine-gateway-lab` found a real, live incident: a site's deploy pipeline stayed green while
actually serving stale content, because its sync step compared file size, not content, and a
byte-length-identical change slipped through undetected. That finding lives inside an internal
lab and names a real site - not something Agentic Tekton's "Governance That Survives the Agent's
Own Confidence" essay can link to directly, and not something a reader can clone and see fail for
themselves.

## Outcome

A small, public, self-contained repository that reproduces the same bug mechanism (generalized,
no specific site named) and its fix, with a test script that asserts both properties empirically -
the bug reproduces, and the fix catches it - so CI stays green only because it's proving something
real, not because nothing bad happened to run. Ships as the runnable companion artefact for the
Field-Journal-synthesis essay this repo unblocks.

## Constraints

- Generalize the mechanism, never name the real site or lab it came from.
- The demonstration has to be the test itself, not a description of a test - CI passing must mean
  "the bug reproduced and the fix caught it," not "nothing crashed."
- Zero real dependencies: plain bash, portable across macOS (BSD stat/shasum) and the GitHub
  Actions Ubuntu runner (GNU stat/sha256sum).
- Public from day one (`dermdunc` account) - no employer detail, secrets, or private names.
