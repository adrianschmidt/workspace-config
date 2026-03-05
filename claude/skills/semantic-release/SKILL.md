---
name: semantic-release
description: "Reference for semantic-release internals, especially git notes for release channel tracking. Use when debugging semantic-release issues, inspecting release channels, or troubleshooting failed releases."
---

# Semantic Release

## Git Notes for Channel Tracking

Semantic-release uses **git notes** to track which release channels each version has been released on. This is stored under the ref `refs/notes/semantic-release`.

### Viewing notes

```bash
# Fetch notes from remote (they are NOT fetched by default with git clone or git fetch)
git fetch origin refs/notes/semantic-release:refs/notes/semantic-release

# View the note for a specific tag
git notes --ref semantic-release show v1.2.3
# Output example: {"channels":[null,"1.2.x"]}

# List all notes
git notes --ref semantic-release list
```

### Channel format

- `null` = the default channel (main branch)
- `"1.2.x"` = a maintenance branch channel
- `"beta"` = a prerelease channel

Example: `{"channels":[null,"1.2.x"]}` means the version was released on both the default channel and the `1.2.x` maintenance branch.

### Manually editing notes

This can be needed to recover from broken state (e.g., after a force push, or to fix missing channel assignments):

```bash
# Add or overwrite a note on a tag
git notes --ref semantic-release add -f -m '{"channels":[null,"1.2.x"]}' v1.2.3

# Push notes to remote
git push origin refs/notes/semantic-release
# Use --force if rewriting existing notes after a rebase
```

Reference: https://github.com/semantic-release/semantic-release/blob/master/docs/support/troubleshooting.md

## How `fetchNotes` Works (v19.x)

Semantic-release fetches notes itself during the release process:

1. First tries: `git fetch --unshallow <url> +refs/notes/semantic-release:refs/notes/semantic-release`
2. If that fails (e.g., repo is already fully cloned), falls back to: `git fetch <url> +refs/notes/semantic-release:refs/notes/semantic-release` with `reject: false` (errors silently swallowed)

### The `fetch-depth: 0` pitfall

If `actions/checkout` uses `fetch-depth: 0`, the repo is not shallow, so the `--unshallow` fetch fails. The fallback fetch runs with `reject: false`, meaning any failure is **silent**. If notes aren't fetched, semantic-release defaults every tag to `channels: [null]`, causing it to try `addChannel` for all versions on maintenance branches.

**Fix:** Don't use `fetch-depth: 0` in the checkout step. Let semantic-release handle unshallowing itself — the `--unshallow` fetch succeeds on a shallow clone and fetches both history and notes in one operation. This is how lime-webclient and lime-crm do it.

## The `addChannel` Step

When releasing on a maintenance branch (e.g., `1.82.x`), semantic-release checks if previous versions have already been associated with that branch's channel. If not, it runs `addChannel` which:

- For npm: runs `npm dist-tag add <pkg>@<version> release-<branch>`
- Updates the git note to include the new channel

If the git notes are missing (see above), semantic-release will incorrectly try to add channels to versions that are already associated, potentially failing if the npm token lacks `packages:write` scope.

## Common Debugging Commands

```bash
# Check what note refs exist on the remote
git ls-remote origin 'refs/notes/*'

# Check a specific tag's channels
git fetch origin refs/notes/semantic-release:refs/notes/semantic-release
git notes --ref semantic-release show <tag>

# Check all tags' notes at once
git log --tags="*" --decorate-refs="refs/tags/*" --no-walk --format="%d%x09%N" --notes="refs/notes/semantic-release*"
```
