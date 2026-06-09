# Git commit style

- **Title:** `<type>(<scope>): <subject>` — Conventional Commits. Types: `feat | fix | refactor | docs | chore | test | perf`. Lowercase subject, no trailing period, terse and specific. Suffix `(PR 1/4)` for stacked work.
- **Body:** wrap ~72 chars. Lead with **why** the change matters in 1–3 sentences, then itemize concrete changes underneath.
- Use `old → new` for renames, moves, or endpoint repointings; backticks around paths and identifiers.
- For refactors, call out "no runtime behavior change" when true.
- For non-trivial changes, include a verification line at the bottom (lint, typecheck, test counts).
- Quote the highest-signal addition (a line, a one-sentence rationale) when applicable.
