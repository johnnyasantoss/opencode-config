---
description: Consolidate session learnings into AGENTS.md (agent memory)
agent: plan
subtask: false
---

You are an agent performing **memory consolidation** at the end of a session. AGENTS.md is your long-term memory — a living document that encodes evergreen principles to improve future sessions. Your job is to process this session's experiences, abstract them into durable constraints, resolve internal conflicts, prune irrelevance, and write the results directly into AGENTS.md (and docs/ if available).

Treat AGENTS.md like a brain's consolidated memory: it should be compact, conflict-free, and contain only what you cannot infer on your own. Every edit is a synapse strengthened or pruned.

## Phase 1 — RECALL

Scan the full conversation from session start. Identify:

1. **User corrections** — where the user overrode your default behavior, especially if it happened more than once
2. **Friction points** — where you hesitated, guessed wrong, took too long, or defaulted to an unwanted pattern
3. **Successful patterns** — approaches that consistently worked well and should be reinforced
4. **Missing guardrails** — what rule, had it existed, would have prevented a mistake or wasted effort this session
5. **Scope issues** — times you over-engineered, under-engineered, or went off-task

Extract concrete events with brief evidence (e.g. "User corrected import style twice", "Agent defaulted to OOP when repo uses functional patterns").

## Phase 2 — AUDIT

Read @AGENTS.md in full. Check for any docs/ directory and read its contents if present. Then detect:

### Contradictions
Two rules that cannot both be followed. Example: "Always add comments" vs. "Avoid superfluous comments" — the agent cannot satisfy both. These **must** be resolved — pick the stronger, discard the weaker.

### Dead memories
Rules that are:
- Already followed natively by capable models (no instruction needed)
- Outdated (referencing removed tools, old conventions)
- Never relevant to the actual work done in sessions

### Vague memories
Rules that fail the **verifiability test**: can a reviewer point at code and say "this follows the rule" or "this violates the rule"? If not, it is aspirational fluff. Either sharpen it into a concrete constraint or remove it.

### Bloated memories
Sections that have grown too long, burying important constraints in noise. The most important memories must be at the top.

### Gaps
What friction this session revealed that AGENTS.md has no rule for.

## Phase 3 — FILTER

Apply these decision rules, ordered by strength:

### Heuristic 1 — Negative constraints over positive directives
Prefer "Do not X" over "Do Y". Research shows negative constraints are more durable and less likely to distract. Positive directives ("follow code style", "handle edge cases") often backfire by shifting focus away from the core task.

### Heuristic 2 — Two corrections = one memory
If the user corrected you on the same thing twice this session, codify it as a negative constraint. Single corrections may be situational; repeated ones reveal a persistent misalignment.

### Heuristic 3 — Don't memorize what the agent already knows
The agent knows TypeScript, React, git, common tooling. Never add rules about standard language conventions, well-known library usage, or universal best practices. Only add what is unique to this repository or this user's workflow.

### Heuristic 4 — Keep memory concise (target ~200 lines)
Longer files dilute adherence. Every line you add should justify itself by answering: "Would removing this cause a mistake in a future session?" If not, cut it.

### Heuristic 5 — Verify before memorizing
Every rule must answer the question: "Would a code reviewer be able to point to specific code and say whether this rule was followed?" Aspirational statements ("write clean code", "be efficient") fail this test and must be sharpened or removed.

### Heuristic 6 — Abstraction over instance
Session-specific details (file names, specific bugs, one-off tasks) must be abstracted into evergreen principles before committing to memory. "The parser in src/parser.ts needs null checks" is not a memory. "When writing parsers, validate input boundaries before processing" is.

### Filtering result
For each candidate change, classify:
- **ADD** — new high-confidence constraint that would prevent future friction
- **REMOVE** — dead memory, contradiction, or unverifiable fluff
- **MODIFY** — existing rule that needs sharpening or scope adjustment
- **DISCARD** — task-specific, one-off, or low-confidence observation (do nothing)

If no candidates survive filtering, report that and stop. Do not fabricate changes for the sake of change.

## Phase 4 — CONSOLIDATE (Write to memory files)

### AGENTS.md

Edit @AGENTS.md directly. Apply all ADD, REMOVE, and MODIFY changes:

1. **Remove** dead memories, contradictions (keep the stronger version), and vague rules
2. **Add** new constraints as negative directives where possible, placed in the right category section
3. **Modify** existing rules that need sharpening — prefer tightening scope over broadening
4. **Resolve contradictions** by keeping the rule that better matches this session's evidence
5. **Reorder** sections so the most important constraints are at the top; secondary preferences at the bottom
6. **Prune** until the file is under ~200 lines. If already bloated, be aggressive.

Preserve the existing section structure (## categories) unless a category is entirely empty after pruning. Maintain the existing voice and formatting conventions of the file.

### docs/ directory (secondary memory)

- If `docs/` does **not** exist: ask the user: "No docs/ directory found. Would you like me to create one for auxiliary memory files?" Use the `question` tool. Do not create it without permission.
- If `docs/` **does** exist: identify which doc files are relevant to the learnings from this session. Edit them to integrate abstracted principles where appropriate. If unsure whether a learning belongs in AGENTS.md or docs/: AGENTS.md is for always-loaded session context; docs/ is for deeper reference material loaded on demand.

### Critical constraints
- **Never commit changes.** The user reviews and commits manually. Memory consolidation is a personal, human-reviewed process.
- **Never delete or rename** files without asking.
- **Prefer localized edits** over rewrites. Do not restructure entire files unless contradictions force it.
- **Do not add explanations or commentary** to AGENTS.md. It is memory, not documentation.

## Phase 5 — REPORT

Output a clean summary:

### Memory Consolidation Report

**Session:** [brief 1-line summary of what the session was about]

| Action | Section | Rule | Rationale |
|--------|---------|------|-----------|
| ADDED | Code Rules | Do not rewrite files unnecessarily; prefer localized changes | Agent rewrote entire file twice when only 5 lines needed changing |
| REMOVED | Tone | Always be verbose | Contradicted by "short answers by default"; session evidence favors conciseness |
| MODIFIED | Git Rules | ... | Sharpened scope from "test before push" to "run `cargo test` before pushing to main" |
| ... | ... | ... | ... |

**AGENTS.md:** [before lines] → [after lines] (delta: ±N)
**docss/:** [created / modified N files / no changes — or "docs/ not present, user opted not to create"]
**Controversies resolved:** [count and brief description of each contradiction removed]
**No changes needed:** [only if no candidates survived filtering — explain why]

---

## Error Handling

- **AGENTS.md not found**: Ask the user where the project's agent instructions file lives. Do not create one without asking.
- **docs/ present but empty**: Treat as "docs/ exists" — write to an appropriate new file if needed.
- **No learnings extracted**: Report "No memory consolidation needed — session did not surface any durable principles worth encoding." Do not fabricate.
- **Changes would exceed ~200 lines significantly**: Warn the user that AGENTS.md is growing too large and suggest moving secondary content to docs/ or splitting into skills.
- **Ambiguous contradiction**: If you cannot determine which of two conflicting rules is correct, present both to the user and ask which to keep.
