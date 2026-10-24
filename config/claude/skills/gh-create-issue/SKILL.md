---
name: gh-create-issue
description: Create a GitHub issue on the repo of the current working directory using the gh CLI. Use when the user asks to open, file, or create a GitHub issue.
---

# Create GitHub Issue

Open an issue on the GitHub repo the user is currently working in.

## Steps

1. Authenticate only via the `GH_TOKEN` environment variable. Check it is set without printing it: `[ -n "$GH_TOKEN" ] && echo set || echo missing`. If missing, tell the user `GH_TOKEN` isn't set in the environment and stop. Never run `gh auth login`, never suggest it, and never echo or log the token.
2. Identify the repo with `gh repo view --json nameWithOwner -q .nameWithOwner`. If it fails (no remote / not a GitHub repo), tell the user and stop.
3. Draft the issue from `$ARGUMENTS` plus conversation context (relevant code, errors, failing tests):
   - Title: short, specific, imperative or descriptive. No emoji unless the user asks.
   - Body: what's wrong or wanted, steps to reproduce or context, expected vs actual. Keep it concise.
   - Labels: only suggest labels that exist (`gh label list`). Don't invent new ones.
4. Show the draft (repo, title, body, labels) and ask the user to confirm. Issues are public and notify people, so never create one without confirmation.
5. On approval, run `gh issue create --repo <owner/repo> --title "..." --body "..."` (add `--label`, `--assignee` only if the user asked). Use `--body-file` for long or multi-line bodies.
6. Report the issue URL on one line.

## Rules

- Never run `gh auth login`/`gh auth token`/`gh auth refresh`; `GH_TOKEN` is the only credential.
- Never paste secrets, tokens, or env values into the issue.
- Check `gh issue list --search "<keywords>"` for obvious duplicates first and mention any you find.
- Don't edit, close, or comment on existing issues unless asked.

## Examples

```
/gh-create-issue                                  # infer the issue from the conversation
/gh-create-issue Login fails when email has a +   # use as the title basis
```
