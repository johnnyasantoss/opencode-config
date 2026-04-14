# Agent Prompt Best Practices

A synthesis of best practices for writing agent system prompts, compiled from OpenAI, Anthropic, AgentWiki, SurePrompts, AI Agents Plus, and AI Tools Atlas.

---

## The 7-Component Framework

Every production agent prompt should contain these sections in order of priority:

| # | Component | Purpose |
|---|-----------|---------|
| 1 | Role Definition | Identity, expertise, persona |
| 2 | Core Instructions | Primary task, goals, priorities |
| 3 | Constraints & Guardrails | Boundaries, limitations, safety |
| 4 | Output Format | Structure, format, length |
| 5 | Tool Instructions | When and how to use tools |
| 6 | Few-Shot Examples | Input/output pairs |
| 7 | Error Handling | Fallback behavior |

---

## 1. Role Definition

Anchor the agent's identity and expertise level. This sets the behavioral baseline for everything that follows.

**Pattern:** "You are a [expertise level] [role] specializing in [domain]. You [key behavioral trait]."

**Good:**
```
You are a senior backend engineer specializing in distributed systems.
You prioritize correctness over cleverness.
```

**Bad:**
```
You are a helpful assistant.
```
> Too vague, no expertise anchor

---

## 2. Core Instructions

Define the primary task and priorities. Be specific about what the agent should do, not just what it is.

**Pattern:** State the mission, then rank priorities.

**Good:**
```
Your task is to review pull requests for security vulnerabilities.
Priority order: (1) security flaws, (2) correctness bugs, (3) performance issues, (4) style.
```

---

## 3. Constraints & Guardrails

Set boundaries using **positive directives** ("do X") rather than negative framing ("don't do Y"). Research shows models follow positive instructions more reliably.

| Approach | Example | Effectiveness |
|----------|---------|---------------|
| Positive (preferred) | "Respond in under 200 words" | More reliable |
| Negative (avoid) | "Don't write long responses" | Less reliable |
| Conditional | "If uncertain, say 'I need more information'" | Most precise |

---

## 4. Output Format

Specify exactly how responses should be structured. This is critical for downstream parsing and consistency.

- Use explicit format markers: JSON schema, markdown headers, numbered steps
- Include field names and types when expecting structured data
- Show the expected shape, not just "return JSON"

---

## 5. Tool Instructions

Tell the agent when, why, and how to use each tool. Include decision criteria.

**Pattern:** "Use [tool] when [condition]. Format: [syntax]. Do not use [tool] for [anti-pattern]."

For each tool, specify **4 elements**:

| Element | Description |
|---------|-------------|
| **USE WHEN** | Positive trigger condition |
| **DO NOT USE** | Negative trigger condition |
| **PRE-CONDITION** | What must be true before calling |
| **POST-CONDITION** | What to do with the result |

**Example:**
```
web_search_exa:
- USE WHEN: Current information not in training data, need recent developments
- DO NOT USE: For general knowledge you can answer directly
- PRE-CONDITION: Formulated a clear search query
- POST-CONDITION: Review results, extract key sources before moving on
```

---

## 6. Few-Shot Examples

Provide 1-3 input/output pairs that demonstrate desired behavior. These are the **single most effective technique** for improving consistency.

```
Example 1:
User: "My payment failed"
Agent: Let me check your account status... [calls check_payment_status tool]
Agent: I see your payment failed due to insufficient funds. Would you like to:
1. Update your payment method
2. Contact billing for payment plan options
```

---

## 7. Error Handling

Define fallback behavior for edge cases, ambiguous inputs, and tool failures.

**Protocol:**
- If a tool fails: Retry once with modified query/input, then explain failure gracefully
- If results are contradictory: Report both values, flag discrepancy, note confidence level
- If insufficient data: State "Insufficient data" rather than speculating
- NEVER fabricate data to fill gaps. Missing data > fabricated data.

---

## Chain-of-Thought Prompting for Agents

Force agents to show their reasoning before acting:

```
Before taking any action:

1. ANALYZE: What is the user asking for?
2. CHECK: Do I have the tools/permissions to help?
3. PLAN: What steps are needed?
4. VERIFY: Are there any risks or edge cases?
5. ACT: Proceed with the plan
```

---

## State-Aware Behavior

For agents with internal loops, guide behavior based on state:

```
If this is the FIRST run on this topic: Do comprehensive research
If previous_research exists: Build on existing findings, don't repeat searches
If error_count > 2: Simplify approach, use only most reliable tools
```

---

## Research Agent Template

```
You are a precise research analyst. You synthesize information from
multiple sources, distinguish fact from speculation, and always cite
your evidence.

For each research query:
1. Search for relevant sources using available tools
2. Cross-reference claims across multiple sources
3. Synthesize findings into a structured response
4. Rate confidence level for each claim

- Ground every claim in provided data or search results
- If evidence is insufficient, explicitly state "Insufficient data"
- Distinguish between: confirmed facts, likely conclusions, speculation
- Never present a single source's opinion as established fact

## Output Format
## Summary [2-3 sentence overview]
## Key Findings [with confidence levels]
## Analysis [deeper discussion]
## Sources [numbered list with URLs]
```

---

## Internal Research Loop Pattern

For deep research agents:

1. **THINK** - Analyze what the user is asking for, identify key concepts and gaps
2. **GATHER** - Initial broad search to understand the landscape
3. **ANALYZE** - Dedupe, cross-reference, understand context, see from user perspective
4. **REFINE** - Search more specifically with learnings/alternatives from analysis
5. **LOG** - Track good sources, authors, learnings, and relevant tangents
6. **GO DEEPER** - Follow promising branches, dive into good sources, explore related links
7. **ASSESS** - Check if goal met or exhausted (max 5 loops). If more needed → back to THINK. If done → write final report

---

## Research Tree Navigation

- When you find a promising source, GO DEEPER: fetch the page, extract key insights, follow related links
- When you discover a relevant tangent, LOG it and evaluate if it's worth pursuing
- Good research is not breadth-first - it's following promising paths until they exhaust
- If a source has multiple sub-topics, decide which are most relevant to the user's goal and explore those
- After diving deep, synthesize what you learned before moving to the next branch

---

## Provider-Specific Tips

### Anthropic (Claude)

- Use XML tags to structure sections: `<role>`, `<instructions>`, `<tools>`
- Place data/context before instructions in long prompts
- Use `<thinking>` tags to enable chain-of-thought reasoning
- Claude mirrors your formatting style — write the way you want responses to look
- Set temperature to 0 for deterministic/factual tasks

### OpenAI (GPT-4o)

- Use markdown structure (headers, bold, lists)
- Place critical instructions at the beginning and end (primacy/recency effect)
- Use explicit chain-of-thought: "First analyze X, then determine Y, finally output Z"
- Specify JSON schema explicitly when expecting structured output

---

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| "You are a helpful assistant" | Too vague, no behavioral anchor | Specify expertise, domain, personality |
| "Don't use bullet points" | Negative framing confuses models | "Use numbered lists for steps" |
| Massive prompt (5000+ words) | Dilutes important instructions | Prioritize, use sections, put key rules first |
| No examples | Inconsistent output format | Add 1-3 few-shot examples |
| "Be creative" | Uncontrolled output variance | Specify exactly what creative means |
| Contradictory instructions | Model picks one randomly | Review for conflicts, establish priority |
| No error handling | Agent hallucinates on edge cases | Define fallback behavior explicitly |

---

## Evaluation Checklist

Before deploying a system prompt, verify:

- [ ] Role is specific with expertise level and domain
- [ ] Instructions are prioritized (numbered or ordered)
- [ ] Constraints use positive framing
- [ ] Output format is explicit with structure shown
- [ ] Tool usage criteria are defined (when/why/how)
- [ ] At least 1 few-shot example is included
- [ ] Error handling covers: ambiguity, tool failure, out-of-scope
- [ ] Tested on 10+ edge cases
- [ ] No contradictory instructions

---

## Key Takeaways

1. **Structure matters more than length** - A well-organized 200-word prompt beats a rambling 2000-word one
2. **Positive directives over negative framing** - Tell the model what to do, not what to avoid
3. **Few-shot examples are the single highest-impact technique** for consistency
4. **Be explicit about tool usage** - When to use, when not to use, pre-conditions, post-conditions
5. **Define error paths** - Tell agents what to do when things go wrong
6. **Match format to model** - XML tags for Claude, markdown for GPT
7. **Compose from modules** for complex agents to keep prompts maintainable and DRY

---

## Sources

- OpenAI: A Practical Guide to Building AI Agents
- Anthropic: Best Practices for Prompt Engineering
- AgentWiki: How to Write and Structure System Prompts
- SurePrompts: AI Agents Prompting Guide
- AI Agents Plus: AI Agent Prompt Engineering Guide 2026
- AI Tools Atlas: AI Agent Prompt Engineering
- Laksh Jain: Building Efficient AI Agents: The Complete Guide
