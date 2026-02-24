## 🚨 PRIORITY RULE: Skills Over Built-in Behavior

When a custom skill matches the user's request, you MUST invoke that skill instead of using built-in approaches. Custom skills override default behavior.

## ⚡ Skills - CHECK THESE FIRST!

**BEFORE starting any task, check if a skill applies:**

| Skill | Use When | Trigger Phrases |
|-------|----------|-----------------|
| `pr-address-feedback` | Responding to PR review comments | "address feedback", "PR review", "review comments", "fixup commit" |
| `pr-review-code` | Reviewing someone else's PR | "review PR", "review this PR", "look at this PR" |
| `pull-request-risk-assessment` | Evaluating change risk per Change Management policy | "risk assessment", "assess risk", "evaluate risk", "change management" |
| `generating-commit-messages` | Creating or improving commit messages | "commit message", "create commit", "amend commit", "fixup commit" |
| `safe-file-operations` | Moving, deleting, or copying files | "move files", "delete files", "rm", "mv", "cp" |
| `6-agent-review` | Deep multi-dimensional PR review | "6 agent review", "deep review", "comprehensive review", "multi-agent review" |

**To use a skill:** Invoke the Skill tool with just the skill name (e.g., `Skill(skill: "pr-address-feedback")`)

---

## General

Please be concise and to the point. Do not flatter the user.

- Do NOT install python packages in the global environment. Our work related repos typically use poetry, and for repos that don't use poetry, I typically have a conda environment that should be used. If in doubt, STOP & ASK!
- When given a url to a GitHub repo, issue, PR, or similar, belonging to the `Lundalogik` organization on GitHub, use the `gh` CLI command to access it.

## Multi-Agent Planning

When you see the "Plan mode is active" system reminder, use the multi-agent planning workflow to generate robust plans informed by multiple perspectives.

### Workflow

1. **Spawn planning agents in parallel** (single message with 3 Task tool calls):
   ```
   Task(subagent_type: radical-planner, prompt: [user's task])
   Task(subagent_type: balanced-planner, prompt: [user's task])
   Task(subagent_type: conservative-planner, prompt: [user's task])
   ```

2. **Spawn meta-synthesizer** with all three plans as input:
   ```
   Task(subagent_type: meta-synthesizer, prompt: [include all three plans and original user query])
   ```

3. **Present the synthesized result** to the user (the meta-synthesizer will format appropriately based on convergence/divergence)

4. **Use ExitPlanMode** tool with the final synthesized plan

### Rationale

The multi-agent approach uses convergence/divergence as a signal:
- **High convergence** = High confidence (all perspectives agree on the approach)
- **Divergence** = Important decision points exist (trade-offs matter, user priorities determine best path)

This approach provides:
- Confidence levels through agreement patterns
- Clear identification of trade-off decisions
- Multiple perspectives on complex problems
- Explicit risk assessment and innovation opportunities

## Testing Stencil based components

The jest command line flag `--testPathPattern` does not work as expected with StencilJS. For example, using the flag `--testPathPattern="info-tile"` will result in the following output: `Ran all test suites matching /i|n|f|o|-|t|i|l|e/i.`. Instead, either run all tests, or stop and ask the user to run the tests manually.
