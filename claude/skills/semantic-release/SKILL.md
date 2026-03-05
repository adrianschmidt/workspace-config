---
name: semantic-release
description: "Reference for semantic-release internals that are hard to find in official docs — especially git notes for release channel tracking, version-specific behavioral differences, and CI pitfalls. Use when debugging semantic-release issues, inspecting release channels, troubleshooting failed releases, investigating addChannel errors, or when the user mentions git notes in a release context. Also use when comparing semantic-release behavior across different major versions."
---

# Semantic Release Internals

This skill covers the non-obvious internals of semantic-release — things that are hard to discover from the official docs or by reading config files.

## Git Notes for Channel Tracking

Semantic-release tracks which release channels each version has been published on using **git notes**. These notes are the source of truth for whether `addChannel` needs to run on a maintenance or prerelease branch.

Git notes are stored under refs that start with `refs/notes/semantic-release`. They are **not** fetched by a normal `git clone` or `git fetch` — you must fetch them explicitly.

### Fetching and viewing notes

```bash
# Fetch notes from remote (required before you can view them)
git fetch origin 'refs/notes/semantic-release*:refs/notes/semantic-release*'

# View the note for a specific tag
git notes --ref semantic-release show v1.2.3
# Example output: {"channels":[null,"1.2.x"]}

# List all note objects
git notes --ref semantic-release list

# View all tags with their notes in one command
git log --tags="*" --decorate-refs="refs/tags/*" --no-walk \
  --format="%d%x09%N" --notes="refs/notes/semantic-release*"

# Check what note refs exist on the remote
git ls-remote origin 'refs/notes/*'
```

### Channel format

The `channels` array in each note tracks where a version has been released:

- `null` — the default channel (main/master branch)
- `"1.2.x"` — a maintenance branch channel
- `"beta"`, `"alpha"` — prerelease channels

Example: `{"channels":[null,"1.2.x"]}` means released on both main and the `1.2.x` maintenance branch.

### Manually editing notes

Needed to recover from broken state (after force push, missing channels, etc.):

```bash
# Add or overwrite a note
git notes --ref semantic-release add -f -m '{"channels":[null,"1.2.x"]}' v1.2.3

# Push notes to remote (use --force after rebase/rewrite)
git push origin refs/notes/semantic-release
```

Reference: https://github.com/semantic-release/semantic-release/blob/master/docs/support/troubleshooting.md#release-not-found-release-branch-after-git-push-force

## Version Differences in Notes Storage

### v19.x (single shared ref)

- **Reads** from: `refs/notes/semantic-release`
- **Writes** to: `refs/notes/semantic-release`
- **Pushes**: `refs/notes/semantic-release`
- **Fetches**: `+refs/notes/semantic-release:refs/notes/semantic-release`

All tags share a single notes ref. This is simpler but means a single ref accumulates all note objects.

### v24.x (per-tag refs with backwards compatibility)

- **Reads** from: both `refs/notes/semantic-release` (old) AND `refs/notes/semantic-release-<tag>` (new), merged together
- **Writes** to: `refs/notes/semantic-release-<tag>` (e.g., `refs/notes/semantic-release-v1.2.3`)
- **Pushes**: `refs/notes/semantic-release-<tag>`
- **Fetches**: `+refs/notes/*:refs/notes/*` (wildcard, catches both old and new)

Each tag gets its own notes ref. The read path merges old and new formats for backwards compatibility, so upgrading from v19 to v24 works without migration. However, going back from v24 to v19 would lose notes written in the new per-tag format.

When manually fixing notes on a repo using v24, write to the per-tag ref:
```bash
git notes --ref semantic-release-v1.2.3 add -f -m '{"channels":[null,"1.2.x"]}' v1.2.3
```

## The `fetchNotes` Mechanism and CI Pitfalls

Semantic-release fetches notes itself as part of its branch discovery phase. The implementation has a subtle failure mode that matters for CI:

1. First tries: `git fetch --unshallow <url> <notes-refspec>`
2. If that fails (any error, including "already complete"), catches and runs: `git fetch <url> <notes-refspec>` with **`reject: false`** — meaning errors are silently swallowed

### The `fetch-depth: 0` problem

When `actions/checkout` uses `fetch-depth: 0`, the repo is fully cloned (not shallow). This means:

1. The `--unshallow` fetch fails (repo is already complete)
2. The fallback fetch runs with `reject: false`
3. If the fallback also fails (e.g., auth URL mismatch), **no error is reported**
4. Notes are missing, so every tag defaults to `channels: [null]`
5. On maintenance branches, semantic-release tries `addChannel` for versions that are already associated with the channel
6. The `addChannel` npm dist-tag command may then fail (e.g., if the token lacks `packages:write` scope)

**Fix:** Don't use `fetch-depth: 0` in the checkout step. Use the default shallow clone (`fetch-depth: 1`). Semantic-release's `--unshallow` fetch will succeed on a shallow repo, fetching both the full history and the notes in one operation.

### Diagnosing missing notes in CI

If a release fails with `addChannel` errors on a maintenance branch, the likely cause is missing notes. Symptoms:

- Error like `npm dist-tag add <pkg>@<version> release-<branch>` failing with 404 or auth errors
- Semantic-release trying to add channels to versions that should already have them
- Log shows "Add channel X to tag vY.Z.W" for versions that were previously released on that branch

To verify: check if the tag actually has the expected channel in its notes (fetch notes locally and inspect). If the note shows the channel but CI still tries to add it, the CI environment isn't fetching notes.

## The `addChannel` Step

When semantic-release runs on a non-default branch (maintenance or prerelease), it checks all reachable tags to see if they've been associated with the current branch's channel. For any that haven't, it runs `addChannel`:

- For npm packages: `npm dist-tag add <pkg>@<version> release-<branch>`
- For GitHub: updates the GitHub Release
- Then updates the git note to include the new channel

The channel name for a maintenance branch defaults to the branch name (e.g., branch `1.82.x` → channel `"1.82.x"`), unless explicitly configured otherwise.

This step only runs on non-default branches. Releases on main use channel `null` and never trigger `addChannel`, which is why notes-related problems only surface on maintenance/prerelease branches.
