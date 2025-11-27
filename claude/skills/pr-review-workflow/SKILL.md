---
name: pr-review-workflow
description: "Systematic workflow for addressing pull request review feedback. Use when handling PR reviews, creating fixup commits, or responding to reviewer comments. Covers reading feedback, creating fixup commits, and posting responses via GitHub CLI."
---

# Handling Pull Request Review Feedback

When the user asks you to address review feedback on a PR, follow these systematic steps:

## 1. Reading Review Comments

Use the GitHub CLI to fetch ALL review comments and feedback:

```bash
# List PRs for current branch (repo name = folder name, usually)
gh pr list --head <branch-name>

# Get comprehensive PR details including all comments and reviews
gh pr view <PR-number> --json title,body,comments,reviews,reviewRequests,commits

# Get PR review comments (line-specific comments)
gh api repos/Lundalogik/<repo-name>/pulls/<PR-number>/comments

# Get formatted PR view
gh pr view <PR-number>
```

**Important:** All repos are in the `Lundalogik` organization. The repo name is generally the same as the folder name, with exceptions like `limeclient.js` repo cloned into `lime-client` folder. When in doubt, ASK the user.

## 2. Address Feedback Systematically

**One Issue Per Commit:**
- Address review feedback ONE item at a time
- Create separate fixup commits for each distinct issue
- This makes the review process clear and traceable

**Use Fixup Commits:**
```bash
# Make your changes to address the feedback
git add <files>

# Create fixup commit targeting the relevant original commit
git commit -m "fixup! <original-commit-subject>

<description of what was fixed>

Addresses review feedback from @<reviewer>"
```

**Fixup Commit Format:**
- Subject: `fixup! <original-commit-subject>`
- Body: Clear description of what was changed
- Footer: `Addresses review feedback from @<reviewer>`

## 3. Responding to Review Comments

**ALWAYS ASK PERMISSION FIRST:**
Before posting any replies to review comments, ASK the user:
- "Should I post replies to the review comments?"
- "Do you want me to respond to @reviewer's feedback?"

**Response Format:**
When given permission, post threaded replies using:
```bash
gh api repos/Lundalogik/<repo-name>/pulls/<PR-number>/comments -X POST \
  --field body="⚡️ <commit-hash>" \
  --field in_reply_to=<comment-id>
```

Use the ⚡️ (zap) emoji to indicate feedback has been addressed, followed by the relevant fixup commit hash.

## 4. Complete Workflow Example

1. **Read feedback:** `gh pr view 63 --json comments,reviews`
2. **Address issues one by one:** Create fixup commits for each item
3. **Ask permission:** "Should I post replies to indicate the feedback has been addressed?"
4. **Post responses:** Use ⚡️ + commit hash format
5. **Summarize:** Provide overview of all changes made

## 5. Best Practices

- **Be systematic:** Don't batch unrelated fixes into one commit
- **Be specific:** Reference exact reviewer suggestions in commit messages
- **Be communicative:** Clear commit messages help reviewers understand changes
- **Be respectful:** Always ask before posting comments on behalf of the user
- **Be thorough:** Address ALL feedback items, don't miss any

## 6. Repository Information

- **Organization:** `Lundalogik`
- **Repo naming:** Usually matches folder name (e.g., `aws-bedrock-gateway`)
- **Exception:** `limeclient.js` repo is in `lime-client` folder
- **When uncertain:** Ask the user for clarification
