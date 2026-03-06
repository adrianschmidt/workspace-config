---
name: 6-agent-review
description: "Multi-agent PR review across 6 dimensions: backward compatibility, code quality, architecture, security, observability, and performance. Use when asked for a deep or comprehensive PR review."
user_invocable: true
---

# 6-Agent PR Review

Review a PR using 6 parallel sub-agents, each focused on a specific dimension, then synthesize into a single consolidated report.

## Instructions

### Step 1: Fetch PR Details and Gather Context

1. Use `gh pr view` and `gh pr diff` to get the PR metadata and full diff.
2. Determine the local clone of the repo. The user's repos are typically at `~/src/<repo-name>`.
3. Create a temporary git worktree for the PR branch in the local clone:
   ```
   git -C ~/src/<repo-name> worktree add /tmp/pr-review-<pr-number> <pr-branch> --detach
   ```
4. Save the worktree path — you will pass it to all sub-agents and clean it up at the end.

#### Cross-PR Context (when applicable)

Check whether the PR description or linked issue references other PRs (e.g., "Requires #123", "Part of #456", "Related: #789"). Also check if the PR's linked issue (if any) has other PRs associated with it:

```
gh pr view <number> --json body,title
gh issue view <linked-issue> --json body,title,comments
gh pr list --search "issue:<linked-issue>"
```

If related PRs exist, fetch their titles and diffs (`gh pr diff <number>`). Include this context in each sub-agent's prompt as "Related PR context" so they can consider cross-PR interactions — but instruct them that findings should focus on the PR under review. The related PRs are background context, not review targets.

Keep this lightweight: titles + diffs of related PRs, not full deep dives. If there are more than 3 related PRs, summarize the others rather than including all diffs.

### Step 2: Spawn 6 Sub-Agents in Parallel

Launch 6 `general-purpose` Task agents **in a single message** (so they run in parallel), using `model: "opus"` for all 6. Each agent receives:
- The **full diff** (the complete output of `gh pr diff`)
- The **PR description/metadata**
- The **worktree path** so they can explore the full codebase with Read, Grep, and Glob
- Any **related PR context** gathered in Step 1 (if applicable)

Each agent has a specific review focus:

1. **Backward Compatibility** — removed/changed public APIs, exports, props, events, protocol changes, behavioral changes, cross-PR coordination risks
2. **Code Quality** — naming, cohesion, error handling, type safety, test coverage, code smells, duplication
3. **Architecture** — component responsibilities, data flow, state management, coupling, separation of concerns, extensibility
4. **Security** — XSS, injection, information disclosure, input validation, authentication, secrets handling
5. **Observability/Monitoring** — logging completeness, log levels, structured data, sensitive data in logs, error context, metrics, correlation
6. **Performance** — render cycles, memory, GC pressure, algorithmic complexity, bundle size, cleanup, caching

**Important instructions to include in each sub-agent's prompt:**

- Do NOT use `gh`, `git`, or other shell commands. All PR information is provided in the prompt. Use Read, Grep, and Glob to explore the codebase at the provided worktree path.
- Do NOT write comments/descriptions on tool calls — just execute them silently.
- **Be thorough.** Read every changed file in the diff carefully. Follow references into the surrounding codebase — if a changed function is called from elsewhere, read those call sites. If a type is modified, check all usages. The goal is to catch every significant issue, not to produce a quick summary.
- **Report what you actually find, not a fixed number of items.** If you find 1 real issue, report 1. If you find 12, report 12. Do not pad your findings with speculative or trivial observations to fill space. Do not truncate your list to fit an arbitrary limit.
- **Calibrate severity honestly.** Only mark something `[High]` if it genuinely should block the merge. `[Medium]` means it should be fixed soon but doesn't block. `[Low]` means nice-to-have. If everything looks good in your dimension, say so — a short "no significant issues found" section is a perfectly valid and useful result.
- **Be concrete.** Every finding must reference specific files, functions, or line ranges. Vague observations like "consider adding more tests" without specifying what's untested are not helpful.
- If related PR context is provided: consider whether changes in this PR interact with or depend on the related PRs, but keep your review focused on the PR under review.

### Step 3: Synthesize into Consolidated Report

Once all 6 agents return, synthesize their findings into the output format below.

**Synthesis guidelines:**
- Do NOT just concatenate — deduplicate, cross-reference, and prioritize.
- **Preserve all significant findings.** If a sub-agent found a real issue, it must appear in the consolidated report. The synthesis step is for deduplication and organization, not for filtering down to a fixed number.
- **Top Recommendations should reflect the actual issues found.** If there are 2 high-severity issues, list 2. If there are 15, list 15. Do not cap at an arbitrary number. If there are no significant issues, the Top Recommendations section should say so rather than padding with minor suggestions.
- **Do not invent findings during synthesis.** The consolidated report should only contain issues that at least one sub-agent actually identified and substantiated.

### Step 4: Clean Up

Remove the temporary worktree:
```
git -C ~/src/<repo-name> worktree remove /tmp/pr-review-<pr-number> --force
```

## Output Format

Use this exact structure:

```markdown
# Consolidated PR Review -- 6 Dimensions

## PR Summary

<2-3 sentence summary of what the PR does, files changed, lines added/removed>

---

## 1. Backward Compatibility -- <VERDICT> <emoji>

<1-2 sentence overview>

- **[High/Medium/Low]** <finding>
- ...
- **Positives:** <what's done well>

## 2. Code Quality -- <VERDICT> <emoji>

<same structure>

## 3. Architecture -- <VERDICT> <emoji>

<same structure>

## 4. Security -- <VERDICT> <emoji>

<same structure>

## 5. Observability -- <VERDICT> <emoji>

<same structure>

## 6. Performance -- <VERDICT> <emoji>

<same structure>

---

## Overall Verdicts

| Dimension | Verdict |
|---|---|
| Backward Compatibility | **<VERDICT>** |
| Code Quality | **<VERDICT>** |
| Architecture | **<VERDICT>** |
| Security | **<VERDICT>** |
| Observability | **<VERDICT>** |
| Performance | **<VERDICT>** |

## Top Recommendations

<numbered list, most important first — include ALL significant issues, not a fixed count>
1. **[Medium from Code Quality]** <recommendation>
2. **[Low from Architecture]** <recommendation>
...
```

## Formatting Rules

- **Verdicts:** SAFE, GOOD, ACCEPTABLE, FAIR, POOR, RISKY
- **Emojis:** use a checkmark for SAFE/GOOD/ACCEPTABLE, a warning sign for FAIR, an X for POOR/RISKY
- **Severity tags:** `[High]` = should fix before merge, `[Medium]` = should fix soon, `[Low]` = nice to have
- **Positives:** Include a "Positives:" line in each section to acknowledge what's done well
- **Findings:** Keep them concrete — cite specific methods, files, or patterns
- **Top Recommendations:** Each recommendation must be prefixed with its severity and source dimension, e.g., `[Medium from Code Quality]`. Actionable items, not just restating findings. Must include suggestion for all [High] severity issues, or warning, if no actionable suggestion can be made, and should include the [Medium] severity issues for which actionable suggestions can be made.
- **Deduplication:** If multiple agents flag the same issue, mention it once in the most relevant section and cross-reference if needed
- **Clean sections:** If a dimension has no significant findings, a brief "No significant issues found" with a Positives line is better than padding with trivial observations
