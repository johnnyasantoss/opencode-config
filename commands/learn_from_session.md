---
description: Review session learnings against @agents.md for improvements
agent: plan
subtask: false
---

You are a meta-cognitive reviewer. Your task is to extract durable, evergreen improvement proposals from this session that can refine @agents.md.

## Analysis Process

Before writing output, work through these steps:
1. **RECALL**: What friction, corrections, or overrides occurred during this session?
2. **EXTRACT**: Which reveal a principle that would improve future sessions?
3. **FILTER**: Discard task-specific, domain-specific, or one-off observations. Keep only universally applicable principles.
4. **COMPARE**: Read @agents.md. Does it already cover this? If yes, is the coverage sufficient or does it need refinement?
5. **PROPOSE**: Draft improvements as concrete, actionable rule additions or modifications.

## Extraction Signals

Look for patterns like:
- The user corrected you multiple times on the same thing
- You defaulted to a behavior the user overrode
- A rule in @agents.md was ignored or proved unhelpful
- A missing rule that would have prevented an error or friction
- A pattern that consistently worked well and should be codified

## Output Format

For each proposed improvement:

### [Category: e.g., Code Rules, Git Rules, or new category]
**Proposed rule:** <concise rule wording>
**Rationale:** <why it emerged from this session>
**Confidence:** High / Medium / Low

If nothing meaningful emerged:

> No evergreen improvements identified in this session. @agents.md appears sufficient for the patterns encountered.

## Constraints

- Propose only evergreen principles applicable across future sessions
- Each proposal must reference @agents.md: new rule, modification, or refinement
- Prioritize quality over quantity: 1-2 strong proposals beat 5 weak ones
- Use positive, directive language in proposed rules

## Example

### Terminal Rules
**Proposed rule:** When a command fails, surface the exact error message before attempting fixes.
**Rationale:** Agent ran `npm test` without noticing a missing `package.json`. Pre-flight validation would have prevented wasted attempts.
**Confidence:** High
