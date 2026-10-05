# faiz-skills

A personal Claude Code marketplace. Add it once, install its plugins on any machine.

## Install

```bash
# In any Claude Code session:
/plugin marketplace add https://github.com/faizrazadec/claude-plugins
/plugin install testsmith@faiz-skills
/plugin install docsmith@faiz-skills
```

Then invoke in any repo:

```
/testsmith:write-tests <path or description of the code to cover>
/docsmith:document-change [setup | PR number | description of the change]
```

## Plugins

- **testsmith** — writes/extends automated tests for new or changed code.
  Discovers the repo's existing test stack, matches its conventions, and writes
  tests that fail when the logic breaks. Stack-agnostic (pytest, vitest, jest,
  go test, playwright, …).
- **docsmith**: keeps docs and the changelog current with every significant
  change. It finds the repo's existing doc owners and changelog style and
  follows them. In a repo without a convention, `setup` adds one-file-per-change
  changelog entries (no merge conflicts), a validator, and a pre-commit hook.
  It makes `AGENTS.md` the agent guide, with `CLAUDE.md` as a symlink, so every
  agent reads the same rules. It checks
  `.gitignore` before choosing a path, and never writes secret values into docs.
