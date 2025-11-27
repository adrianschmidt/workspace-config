---
name: generating-commit-messages
description: "Generates clear commit messages following conventional commit conventions. Use when creating commits, suggesting commit messages, amending commits, creating fixup commits, or any operation involving git commit messages."
---

# Generating Commit Messages

## Instructions

1. Run `git diff --staged` to see changes
2. I'll suggest a commit message adhering to conventional commit message conventions.

## Best practices

- Use present tense with the imperative mood.
- Explain what and why, not how

## Fixup and Amend Commits

### `amend!` Commit Format

When creating an `amend!` commit to update both the content AND commit message of a target commit:

1. **First line**: Identifies the target commit using `amend!` prefix
2. **Second line**: Blank line
3. **Third line**: The NEW subject line (even if unchanged from original)
4. **Fourth line onwards**: The new commit message body

**Example:**
```
amend! fix: old commit message subject

fix: new commit message subject

New commit message body explaining the changes.
```

**IMPORTANT**: Even if the subject line isn't changing, you must still include it again after the blank line. The first line with `amend!` is only used to identify the target commit during `git rebase --autosquash`.

### `fixup!` Commits

For `fixup!` commits (content changes only, no message update), just use:
```
fixup! original commit subject

A concise description of the changes made in the fixup. This message will be
discarded when the fixup is applied, so it is only for the benefit of the
developer and the reviewer.
```

## Audience Awareness

When writing commit messages:

- **Never reference our conversation** - Don't mention "Option A/B", "as discussed", "per your request", etc. Write for developers who won't have seen our chat.
- **Write for the team** - Commits will be read by other developers. Explain the "why" in a way that stands alone without our conversation context.
- Do not include Claude Code attribution in commit messages.

**Bad examples:**
- "Using Option B approach as discussed"
- "Removed oldFunction since we decided it wasn't needed"
- ```
  🤖 Generated with [Claude Code](https://claude.com/claude-code)

  Co-Authored-By: Claude <noreply@anthropic.com>
  ```
