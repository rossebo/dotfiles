---
name: code-review
description: Review React/TypeScript frontend and Python/FastAPI backend code for bugs, security vulnerabilities, and performance problems. Use when the user asks for a code review, wants feedback on a diff/PR/staged changes, or mentions reviewing React or FastAPI code.
---

# Code Review (React + Python/FastAPI)

Reviews code for **bugs, security vulnerabilities, and non-performant patterns** only.
Do NOT flag lint/style/formatting issues (biome, ruff, eslint, prettier, black, etc. already handle that) — skip anything a linter or formatter would catch.

## What to review (in priority order)

1. Uncommitted changes: `git diff` (unstaged) and `git diff --staged`.
2. If none, the current PR's diff (e.g. `gh pr diff`, or diff against the base branch).
3. If neither applies, ask the user which files or scope to review.

Only review changed/added lines and their immediate context — do not audit the entire file unless asked.

## Process

1. Determine scope per above.
2. Identify file types: `.tsx`/`.jsx`/`.ts`/`.js` → React rules; `.py` → Python/FastAPI rules.
3. Load the relevant reference file(s):
   - React/TypeScript → [reference/react.md](reference/react.md)
   - Python/FastAPI → [reference/python-fastapi.md](reference/python-fastapi.md)
   - Codestyle - If the repo contains a Codestyle.md.
4. Check each changed hunk against the bug/security/performance patterns in the reference. Ignore anything purely stylistic.
5. Assign a severity to every finding:
   - 🔴 Critical — bug, security vulnerability, or correctness issue. Must fix.
   - 🟡 Should fix — non-performant pattern, risky design, missing error handling.
   - 🟢 Suggestion — minor improvement, not blocking.
6. Output findings **sorted by severity** (all 🔴 first, then 🟡, then 🟢). Within a severity, group by file.
7. If a finding is genuinely ambiguous or you're not confident about intent, ask the user to clarify rather than guessing.

## Output format

Be short, concise, and instructional. No filler words, no praise padding, no restating the code. Use this exact structure:

```
🔴 Critical
- `path/file.py:42` — <one-line problem statement>
  Fix: <concrete instruction>

🟡 Should fix
- `path/file.tsx:17` — <one-line problem statement>
  Fix: <concrete instruction>

🟢 Suggestion
- `path/file.py:8` — <one-line problem statement>
  Fix: <concrete instruction>
```

If a severity group has no findings, omit that group entirely. If there are zero findings, say so in one short line (e.g. "No bugs, vulnerabilities, or performance issues found.").

## Rules

- One bullet per issue. No multi-paragraph explanations.
- "Fix:" must be an instruction the author can act on directly, not a vague suggestion.
- Never flag: naming, formatting, import order, unused-var-style lint issues, or anything a linter/formatter owns.
- Do flag: logic bugs, race conditions, injection/auth/secret-handling vulnerabilities, N+1 queries, unbounded loops/memory growth, missing input validation with security impact, blocking calls in async code, stale closures, missing cleanup/cancellation, unmemoized expensive work causing real re-render cost.
- If the user's intent or the correct fix is unclear, ask a clarifying question instead of assuming.
