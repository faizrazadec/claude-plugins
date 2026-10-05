---
name: document-change
description: Keep a repo's docs and changelog current with a change. Use when finishing a feature, infra or deploy change, migration, or anything that alters how the system works or is operated, or when the user asks to "document this", "update the docs", "add a changelog entry", "write a runbook" or "set up a changelog". It discovers the repo's existing doc owners and changelog style first. Where none exists, `setup` adds one-file-per-change changelog entries (no merge conflicts) plus a validator.
argument-hint: "[setup | PR number | description of the change]"
---

# Document a change

Update the **current** docs that own the changed behavior, and add a changelog
entry **only** when the change is significant. Both go in the same PR as the
change, in the repo's own conventions.

Two modes:
- **`setup`** gives a repo the docs and changelog structure when it has none (step 2).
- **Default:** document the change in front of you (steps 1, 3, 4 and 5). If the
  change deserves an entry and the repo has no changelog yet, run step 2 first
  and say so. Never set up a changelog for a change that doesn't need an entry.

## The rule that matters

**Docs describe what is true now. The changelog records what changed.** Never
substitute one for the other.
- A changelog entry does not replace updating the doc that owns the behavior.
- A doc never narrates history: no "we moved from X to Y on Tuesday".
- When the prose and the code disagree, the code wins. Fix or delete the prose
  in the same change.

## 1. Understand the change, then find its owners

- Read the diff, or PR `$ARGUMENTS` with `gh pr view` / `gh pr diff`. Say in one
  sentence what changed for a user, an operator or a developer. If you can't,
  read more before writing anything.
- Find where this repo already documents things. Look for `README.md` files,
  `docs/`, `runbooks/`, `infra/README.md`, `CONTRIBUTING.md`, `AGENTS.md` and
  `CLAUDE.md` (often a symlink to `AGENTS.md`), plus any index file. Follow what they say about documentation.
  Their rules override this skill.
- Find the existing changelog style:
  - a single `CHANGELOG.md` in Keep a Changelog style;
  - fragment files (`changelog/entries/`, `.changeset/`, `changes/`,
    `newsfragments/`);
  - release-please, or another generated changelog.

  **Match whatever exists. Never introduce a second changelog system.**
- **Check `.gitignore` before choosing any path:** `git check-ignore -v <path>`.
  Some repos ignore `docs/` or `plans/` as local scratch. Never force-add an
  ignored path. Put the doc next to the code it describes instead, for example
  `infra/runbooks/`.

## 2. `setup`: only when the repo has no changelog convention

Copy these from this skill's `assets/` and adapt them:

| Asset | Goes to | Adapt |
| --- | --- | --- |
| `CHANGELOG.md` | repo root | Project name. If a `CHANGELOG.md` already exists, keep its history: link to it or move it into `changelog/archive/`, never delete it. |
| `changelog-README.md` | `changelog/README.md` | Replace `OWNER/REPO` with the real GitHub repo (`gh repo view --json nameWithOwner`). Adjust the "when to add" list to the project. |
| `check_changelog_entries.py` | `scripts/check_changelog_entries.py` | Nothing. It uses only the standard library and works from any directory. |
| `pre-commit` | `.githooks/pre-commit` (`chmod +x`) | Nothing. Use it only if the repo has no hook manager (see below). |

### Agent file: `AGENTS.md`, with `CLAUDE.md` as a symlink

`AGENTS.md` is read by every coding agent: Codex, Cursor, Gemini, Copilot and
Claude Code. Keep one source of truth:

- **Neither file exists:** create `AGENTS.md`, then `ln -s AGENTS.md CLAUDE.md`.
- **Only `CLAUDE.md` exists:** `git mv CLAUDE.md AGENTS.md`, then
  `ln -s AGENTS.md CLAUDE.md`. Retitle the header so it addresses all agents and
  says `CLAUDE.md` is a symlink. Update any references to `CLAUDE.md` in docs.
- **Both exist as separate files:** don't merge them without asking. Add the
  rule to `AGENTS.md` and mention that the two differ.
- **Already a symlink:** edit `AGENTS.md` only.

Then add a short "Docs and changelog" section to `AGENTS.md`:
- **Before opening a PR**, decide on docs and the changelog for the whole branch.
- A change updates its owning doc in the same PR.
- Significant changes add one entry file. Nobody appends to `CHANGELOG.md`.
- The pre-commit hook validates entries, and the section says how to enable it.

Symlinks need `core.symlinks` on Windows. If the team develops on Windows, use
a one-line `CLAUDE.md` containing `@AGENTS.md` instead.

### Pre-commit check: validates the format, never demands an entry

- **The repo already has a hook manager** (`.pre-commit-config.yaml`, husky,
  lefthook): add a hook to it that runs `python3 scripts/check_changelog_entries.py`
  when `CHANGELOG.md`, `changelog/` or the checker are staged. Don't add a second
  hook system.
- **No hook manager:** copy `assets/pre-commit` to `.githooks/pre-commit` and
  `chmod +x` it. Git never turns on hooks from a clone by itself, so enable it:
  - **If the repo has a `package.json`** (at the root or in an app folder) with
    no `prepare` script: add
    `"prepare": "git config core.hooksPath .githooks || true"`. Every
    `pnpm install` / `npm install` then turns it on, and `|| true` keeps CI and
    hosting builds from failing.
  - **Otherwise:** put `git config core.hooksPath .githooks` (once per clone)
    in the README or `AGENTS.md` setup section.
- **Test it.** Run `git config core.hooksPath .githooks`, stage a deliberately
  bad entry and commit. The commit must be rejected. Then unstage and delete the
  bad file.
- **CI:** if the repo already runs CI on PRs, add the checker as a step there.
  Don't add a CI system just for this.

Add first entries only for significant changes that already shipped and have
real PR links. Don't invent history.

## 3. Update the docs that own the change

For each owner found in step 1, edit it so it is true after this change.

| The change affects | Typical owner |
| --- | --- |
| How to run, build or test | `README.md`, `CONTRIBUTING.md`, the agent file's commands section |
| Deploys, infra, environments, env vars, DNS, rollback | the infra README and a runbook |
| An operational procedure (cutover, recovery, rotation) | a runbook with checklists and exact commands |
| Architecture or a contract between services | the architecture doc for that area |
| Stale guidance an agent would follow | `AGENTS.md` (edit it, not the `CLAUDE.md` symlink) |

- **No owner yet?** Create one next to similar docs and link it from the nearest
  index or README. A doc nobody can find doesn't exist.
- **Runbooks hold exact commands and checks:** copy-pasteable commands, how to
  verify ("`/health` returns `database: connected`"), and how to roll back. Mark
  a temporary runbook, such as a one-off cutover, with when to delete it.
- **Record the why behind non-obvious choices** in one or two lines, for example
  "SSM over Secrets Manager: free; nothing needs rotation".
- **Never write secret values:** no keys, tokens, passwords or private URLs with
  credentials. Name where the secret lives (SSM path, vault, console page).
  Account IDs, hostnames and resource names are fine.
- **Keep it short.** Tables and bullets beat paragraphs. Don't document what the
  code already makes obvious.

## 4. Add a changelog entry, only if warranted

**Default to none.** Add one only if the change would still deserve a line in a
monthly summary six weeks later. Qualifying changes affect:
- user, admin or operator workflows;
- security or permissions;
- stored data or migrations;
- deploy, rollback or recovery;
- architecture or contracts;
- workflows the whole repo must follow;
- deprecations and removals.

Skip it for:
- cosmetic changes;
- small bug fixes;
- tests;
- refactors;
- dependency bumps;
- doc typo fixes.

One PR usually produces zero entries or one. Never split one result into several
entries.

In the fragment model, create `changelog/entries/YYYY-MM-DD-kebab-slug.md`:

```markdown
---
date: YYYY-MM-DD
area: deployment
kind: changed        # added | changed | fixed | deprecated | removed | security
---

# Outcome-oriented title (what is true now)

One short paragraph or a few bullets: what changed and why it matters.

- PR: [#123](https://github.com/OWNER/REPO/pull/123)
- Docs: [deploy runbook](../../path/to/runbook.md)
```

- Keep it under 40 lines, with at least one link: the PR, plus the current doc.
- Describe the outcome and its impact, not how the work went.
- Before writing a PR number, check it with `gh pr list` / `gh pr view`. If the
  PR doesn't exist yet, open it first, or add the link in a follow-up commit
  before merging.

In a single-file style, add one line under the right `Unreleased` heading.

If the repo has no changelog at all and this change qualifies, run step 2
first and tell the user you set it up.

## 5. Verify, then hand off

- Run the repo's checker if it has one, for example
  `python3 scripts/check_changelog_entries.py`.
- Check every relative link you added resolves, both in the docs and in the
  entry.
- `git check-ignore` returns nothing for every new file, so it will be committed.
- Commit the docs in small commits that match the repo's commit style, in the
  same PR as the change or right behind it.
- Report in a few lines: which docs you updated or created, and whether you
  added a changelog entry (and why or why not). Mention anything you
  deliberately left out, such as CI wiring.
