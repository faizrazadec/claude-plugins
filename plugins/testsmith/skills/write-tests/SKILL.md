---
name: write-tests
description: Write or extend automated tests for new or changed code. Use when the user adds a feature, fixes a bug, or asks to "write tests", "add tests", "cover this", "test this". Works in any repo and language — it discovers the existing test stack and conventions first, then writes tests that actually fail when the logic breaks (never vacuous change-detectors).
argument-hint: "[path or description of the code to cover]"
---

# Write tests

Given new or changed code, add the **smallest** set of tests that will catch a
future regression — written in the repo's existing style, and verified to fail
when the logic is broken.

## The one rule that matters

**Read and trace the code before writing a single assertion.** A test written
without understanding the flow asserts whatever the code currently does —
including its bugs — so it catches nothing and locks the bug in. Understanding
first is non-negotiable. The laziness is in the *amount* of test code, never in
the reading. If tracing reveals a real bug (untestable code usually is buggy
code), say so plainly instead of writing a test that hides it.

## Steps

### 1. Understand the change
- Read the new/changed code and trace it end to end: inputs, branches, error
  paths, and every caller (grep for callers of the function you're touching).
- State the **behavior contract**: what must stay true? The success case, plus
  the 2–3 error/edge cases that actually matter (empty, null, boundary, failure,
  concurrency).
- If you can't state what would make the code *wrong*, stop and read more — don't
  write a test yet.

### 2. Discover the existing setup — match it, never reinvent
- Find the test runner and config already in the repo before writing anything:
  pytest/vitest/jest/go test/rspec/playwright/… Look for test config files, a
  `tests/`/`__tests__` dir, existing `test_*.py` / `*.test.*` / `*_test.go`
  files, and the package manager (uv/poetry/pip, npm/pnpm/yarn, cargo, go).
- Open 1–2 existing tests and **copy their conventions**: fixture style, imports,
  naming, and how they fake/override services (dependency overrides, in-process
  clients, test doubles).
- **Never add a new framework or dependency if one is already in use.** If NO
  test setup exists at all, bootstrap the minimal one for the repo's stack and
  say so in one line.

### 3. Pick the lowest layer that captures the logic
- Pure logic / functions → **unit test**.
- HTTP handler / route → **API test** against the app in-process; fake the
  DB/services via the repo's existing override pattern — don't hit real infra.
- Component with real logic (forms, conditional rendering, state) → **component
  test**. Skip trivial presentational components.
- A journey that spans the whole stack → **one E2E**, not ten.
- Prefer the fast, hermetic layer. Push to E2E only what only E2E can catch.

### 4. Write the smallest test that fails when the logic breaks
- One clear behavior per test; assert the real contract, not incidental output.
- Cover the main success path **plus** the key error/edge cases from step 1.
- Keep tests hermetic and deterministic: no real network/DB/clock/random unless
  the repo's pattern already handles them. Pin timezone/seed when output depends
  on them.
- Match the repo's assertion style and helpers.

### 5. Run it — and prove it's not vacuous
- Run the new tests; they must pass.
- Then confirm they would **FAIL if the logic broke**: temporarily break the code
  (or invert the assertion) and see red, or reason precisely about which failing
  line flips the assertion. A test that cannot fail is worse than no test —
  delete it.
- Run the surrounding suite to confirm you didn't break neighbors.

## Refuse these anti-patterns
- Asserting current output blindly ("snapshot everything") — locks in bugs.
- Over-mocking until the test only exercises the mocks.
- Testing the framework, stdlib, or a third-party library instead of your code.
- One giant test that can't tell you *what* broke — split by behavior.
- Adding a second test framework alongside the one already in use.

## Output
Tests first, in the repo's style, smallest diff that covers the contract. Then
≤3 lines: what you covered, what you deliberately left out (and why), and the
result of running them.
