# Session Log: Green CI, Stale Deploy

## 2026-07-22 - Initial scaffold

Project scaffolded as **factory-output**. A minimal, runnable repro of a real bug class: a size-only sync step lets a byte-length-identical content change ship as a silent stale deploy while every CI signal stays green.
