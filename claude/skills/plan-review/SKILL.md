---
name: plan-review
description: "Multi-agent review of implementation plans across 5 dimensions: completeness, feasibility, architecture, risk, and scope. Use when asked to review a plan before execution."
user_invocable: true
---

# 5-Agent Plan Review

Review an implementation plan using 5 parallel sub-agents, each focused on a specific dimension, then synthesize into a single consolidated report.

## Instructions

### Step 1: Locate the Plan and Codebase

1. If the user provided a file path argument, use it directly.
2. If no path was given, find the most recently modified `.md` file in `~/.claude/plans/`.
3. If no plan file can be found, ask the user.
4. Read the full plan content using the Read tool.
5. Determine the codebase root:
   - If the plan references a specific repo or file paths, infer the repo root.
   - If the current working directory is a git repo, use that.
   - The user's repos are typically at `~/src/<repo-name>`.
   - If unclear, ask the user.

### Step 2: Spawn 5 Sub-Agents in Parallel

Launch 5 `general-purpose` Task agents **in a single message** (so they run in parallel), using `model: "opus"` for all 5. Each agent receives:
- The **full plan text**
- The **codebase root path** so they can explore the full codebase with Read, Grep, and Glob

Each agent has a specific review focus:

1. **Completeness** -- Are all necessary steps present? Look for: missing error handling steps, missing test updates, missing config/build changes, unaddressed edge cases, implicit dependencies between steps, missing cleanup or migration steps, forgotten consumers of modified APIs, barrel exports, type definitions. Verify against the codebase that the plan accounts for all files that would need changing.

2. **Feasibility & Accuracy** -- Can each step be executed as described? Verify: referenced files/paths exist, APIs and interfaces match what the plan assumes, patterns described match actual codebase patterns, version/dependency assumptions are correct. **Do NOT trust the plan's assertions -- check them against the actual code.** Flag any incorrect assumptions, outdated references, or misunderstood interfaces. Also consider edge cases and whether the plan would actually produce the stated goal.

3. **Architecture & Design** -- Does the proposed approach fit the codebase? Check: consistency with existing patterns and conventions, appropriate separation of concerns, coupling and cohesion, whether simpler alternatives using existing abstractions exist, whether existing utilities or base classes are being ignored, over-engineering or under-engineering for the problem scope, backward compatibility and migration considerations.

4. **Risk & Rollback** -- What could go wrong during execution? Look for: breaking changes to public APIs or shared interfaces, data migration risks, irreversible operations, steps with no rollback path, cross-repo coordination needs, race conditions during deployment, impact on existing consumers, deployment ordering concerns, and failure modes at each step.

5. **Scope & Efficiency** -- Is the plan right-sized for the goal? Look for: unnecessary steps or gold-plating, opportunities to simplify, steps that could be deferred to follow-up work, over-engineering, new patterns introduced where existing ones would suffice, whether the plan could achieve the same result more directly. Also flag missing steps that are actually necessary despite seeming out of scope.

**Important instructions to include in each sub-agent's prompt:**
- Do NOT use `gh`, `git`, or other shell commands. All plan information is provided in the prompt. Use Read, Grep, and Glob to explore the codebase at the provided path.
- Do NOT write comments/descriptions on tool calls -- just execute them silently.
- Be concrete and specific. Cite exact file paths, line numbers, function names, and code snippets to support your findings.
- If the plan is vague on a point, flag it -- vagueness in a plan is itself a finding.
- Provide findings as a structured list with severity tags: `[High]`, `[Medium]`, `[Low]`.
- Include a "Positives:" line noting what the plan does well in your dimension.

### Step 3: Synthesize into Consolidated Report

Once all 5 agents return, synthesize their findings into the output format below. Do NOT just concatenate -- deduplicate, cross-reference, and prioritize.

Assign an overall readiness assessment:
- **READY** -- No [High] issues. Plan is sound, execute with confidence.
- **NEEDS REVISION** -- Has [High] issues but plan is fundamentally sound. Fix the flagged items first.
- **NOT READY** -- Plan has structural problems or critical gaps. Major revision required.

## Output Format

Use this exact structure:

```markdown
# Plan Review -- 5 Dimensions

## Plan Summary

<2-3 sentence summary of what the plan proposes, its scope, and the primary areas affected>

---

## 1. Completeness -- <VERDICT> <emoji>

<1-2 sentence overview>

- **[High/Medium/Low]** <finding>
- ...
- **Positives:** <what the plan covers well>

## 2. Feasibility & Accuracy -- <VERDICT> <emoji>

<same structure>

## 3. Architecture & Design -- <VERDICT> <emoji>

<same structure>

## 4. Risk & Rollback -- <VERDICT> <emoji>

<same structure>

## 5. Scope & Efficiency -- <VERDICT> <emoji>

<same structure>

---

## Overall Verdicts

| Dimension | Verdict |
|---|---|
| Completeness | **<VERDICT>** |
| Feasibility & Accuracy | **<VERDICT>** |
| Architecture & Design | **<VERDICT>** |
| Risk & Rollback | **<VERDICT>** |
| Scope & Efficiency | **<VERDICT>** |

## Readiness Assessment

**<READY / NEEDS REVISION / NOT READY>**

<1-2 sentence justification>

## Top Recommendations

<numbered list, most important first -- actionable changes to the plan>

## Suggested Amendments

<If any [High] severity findings, provide concrete text to add/change in the plan. If no [High] findings, omit this section.>
```

## Formatting Rules

- **Verdicts:** SOLID, GOOD, ACCEPTABLE, FAIR, WEAK, INADEQUATE
- **Emojis:** use a checkmark for SOLID/GOOD/ACCEPTABLE, a warning sign for FAIR, an X for WEAK/INADEQUATE
- **Severity tags:** `[High]` = must address before executing the plan, `[Medium]` = should address but not blocking, `[Low]` = worth considering
- **Positives:** Include a "Positives:" line in each section to acknowledge what the plan does well
- **Findings:** Keep them concrete -- cite specific files, patterns, or code from the codebase
- **Top Recommendations:** Actionable amendments to the plan, not just restating findings. Must include a suggestion for all [High] severity issues.
- **Deduplication:** If multiple agents flag the same issue, mention it once in the most relevant section and cross-reference if needed
