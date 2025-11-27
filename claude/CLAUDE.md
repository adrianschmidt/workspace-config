## General

NO SYCOPHANTING! Thank you.

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

---

**Note:** Context-specific instructions are available as skills:
- `safe-file-operations` - Guidelines for destructive file operations
- `commit-guidelines` - Best practices for commit messages and code comments
- `pr-review-workflow` - Systematic workflow for handling PR review feedback
