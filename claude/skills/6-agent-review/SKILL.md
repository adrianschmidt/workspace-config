---
name: 6-agent-review
description: "Multi-agent PR review across 6 dimensions: backward compatibility, code quality, architecture, security, observability, and performance. Use when asked for a deep or comprehensive PR review."
user_invocable: true
---

# 6-Agent PR Review

Review a PR using 6 parallel sub-agents, each focused on a specific dimension, then synthesize into a single consolidated report.

## Instructions

### Step 1: Fetch PR Details

Use `gh pr view` and `gh pr diff` to get the PR metadata and full diff.

### Step 2: Spawn 6 Sub-Agents in Parallel

Launch 6 `general-purpose` Task agents **in a single message** (so they run in parallel). Each agent receives the full diff and PR description, with a specific review focus:

1. **Backward Compatibility** — removed/changed public APIs, exports, props, events, protocol changes, behavioral changes, cross-PR coordination risks
2. **Code Quality** — naming, cohesion, error handling, type safety, test coverage, code smells, duplication
3. **Architecture** — component responsibilities, data flow, state management, coupling, separation of concerns, extensibility
4. **Security** — XSS, injection, information disclosure, input validation, authentication, secrets handling
5. **Observability/Monitoring** — logging completeness, log levels, structured data, sensitive data in logs, error context, metrics, correlation
6. **Performance** — render cycles, memory, GC pressure, algorithmic complexity, bundle size, cleanup, caching

Note! Tell the agents to not write comments explaining what they are doing when they run commands. That makes it so that the user has to manually approve every single command, regardless of whether the command is already on the allow-list.

### Step 3: Synthesize into Consolidated Report

Once all 6 agents return, synthesize their findings into the output format below. Do NOT just concatenate — deduplicate, cross-reference, and prioritize.

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

<numbered list, most important first>
```

## Formatting Rules

- **Verdicts:** SAFE, GOOD, ACCEPTABLE, FAIR, POOR, RISKY
- **Emojis:** use a checkmark for SAFE/GOOD/ACCEPTABLE, a warning sign for FAIR, an X for POOR/RISKY
- **Severity tags:** `[High]` = should fix before merge, `[Medium]` = should fix soon, `[Low]` = nice to have
- **Positives:** Include a "Positives:" line in each section to acknowledge what's done well
- **Findings:** Keep them concrete -- cite specific methods, files, or patterns
- **Top Recommendations:** Actionable items, not just restating findings.
- **Deduplication:** If multiple agents flag the same issue, mention it once in the most relevant section and cross-reference if needed
