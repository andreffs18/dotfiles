---
name: commit-and-push
description: Commit all staged/unstaged changes and push to the current remote branch. Use when the user asks to commit and push.
---

# Commit & Push

Commit all staged/unstaged changes and push to the current remote branch.

## Rules

- Commit message: emoji prefix + one brief phrase. No body, no description, no co-author line.
- Choose the emoji based on the nature of the change (📊 analytics, 🐛 fix, ✨ feature, ♻️ refactor, 📝 docs, etc.)
- Stage only relevant files — never `git add -A` blindly. Skip secrets, env files, and unrelated untracked files.
- Push to the current branch's remote after committing.
- If a pre-commit hook fails due to a worktree/path issue (not a real lint/test failure), skip it with `--no-verify` and tell the user why.
- Never amend published commits. Never force-push.

## Steps

1. Run `git status` and `git diff` to understand what changed.
2. Stage the relevant files.
3. Commit with a single-line message: `<emoji> <brief phrase>`.
4. Push to the current branch on the remote.
5. Report the commit SHA and push destination in one line.

## Arguments

If the user passes a message via `$ARGUMENTS`, use that as the brief phrase (still prepend an appropriate emoji). Otherwise infer it from the diff.

## Examples

```
/commit-and-push                          # infer message from the diff
/commit-and-push Add GoatCounter analytics  # use provided message, prepend emoji
/commit-and-push Fix broken footer link
```
