# faiz-skills

A personal Claude Code marketplace. Add it once, install its plugins on any machine.

## Install

```bash
# In any Claude Code session:
/plugin marketplace add https://github.com/faizrazadec/claude-plugins
/plugin install testsmith@faiz-skills
```

Then invoke in any repo:

```
/testsmith:write-tests <path or description of the code to cover>
```

## Plugins

- **testsmith** — writes/extends automated tests for new or changed code.
  Discovers the repo's existing test stack, matches its conventions, and writes
  tests that fail when the logic breaks. Stack-agnostic (pytest, vitest, jest,
  go test, playwright, …).
