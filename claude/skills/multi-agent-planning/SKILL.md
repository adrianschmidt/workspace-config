---
name: multi-agent-planning
description: Multi-perspective planning workflow that spawns radical, balanced, and conservative planning agents in parallel, then synthesizes their output. Use this skill whenever plan mode is active (you see the "Plan mode is active" system reminder). This skill and superpowers:writing-plans serve the same purpose — only one should be enabled at a time.
disable-model-invocation: true
---

# Multi-Agent Planning

When plan mode is active, use this workflow to generate robust plans informed by multiple perspectives.

## Workflow

1. **Spawn planning agents in parallel** (single message with 3 Agent tool calls):
   ```
   Agent(subagent_type: radical-planner, prompt: [user's task])
   Agent(subagent_type: balanced-planner, prompt: [user's task])
   Agent(subagent_type: conservative-planner, prompt: [user's task])
   ```

2. **Spawn meta-synthesizer** with all three plans as input:
   ```
   Agent(subagent_type: meta-synthesizer, prompt: [include all three plans and original user query])
   ```

3. **Present the synthesized result** to the user (the meta-synthesizer will format appropriately based on convergence/divergence)

4. **Use ExitPlanMode** tool with the final synthesized plan

## Why this approach works

The multi-agent approach uses convergence/divergence as a signal:
- **High convergence** = High confidence — all perspectives agree on the approach
- **Divergence** = Important decision points exist — trade-offs matter, user priorities determine the best path

This gives you:
- Confidence levels through agreement patterns
- Clear identification of trade-off decisions
- Multiple perspectives on complex problems
- Explicit risk assessment and innovation opportunities
