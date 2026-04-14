---
name: skill-conversion
description: >
  This skill should be used when the user asks to "convert a skill", "migrate a skill to OpenCode",
  "make a skill OpenCode compatible", "adapt a Claude Code skill", or needs to transform
  an existing skill from VS Code, Cursor, or the open skills ecosystem into OpenCode-native format.
version: 0.1.0
---

# OpenCode Skill Conversion Prompt

Use this prompt to convert a general-purpose skill (from Claude Code, VS Code, Cursor, or the open skills ecosystem) into an OpenCode-native skill.

---

## The Conversion Task

You are converting an existing skill to be OpenCode-specific. Your goal is to create a skill that:
1. Follows OpenCode's skill structure and conventions
2. Uses OpenCode's preferred frontmatter fields
3. Integrates with OpenCode's skill discovery system
4. Follows OpenCode's progressive disclosure principles
5. Uses OpenCode's writing style requirements

---

## Step 1: Analyze the Source Skill

Before writing anything, analyze the source skill:

**Identify:**
- What domain/task does this skill cover?
- What trigger phrases activate it?
- What resources does it bundle (scripts, references, examples)?
- What is the complexity level (simple knowledge vs. comprehensive)?

**Map the structure:**
```
source-skill/
├── SKILL.md          → Does it have frontmatter? What fields?
├── references/       → What detailed docs?
├── scripts/         → What utilities?
├── examples/        → What working examples?
└── assets/          → What templates?
```

---

## Step 2: Apply OpenCode Conventions

### Frontmatter Transformation

**Required fields:**
```yaml
---
name: [lowercase-hyphenated-name]  # Must match directory name
description: >
  [Third-person trigger description - 1-1024 chars]
  This skill should be used when the user asks to "[phrase1]", "[phrase2]".
---
```

**Standard optional fields:**
```yaml
version: 0.1.0                          # Version for tracking
license: MIT                             # License identifier
compatibility: opencode                  # or "opencode, claude"
metadata:                                # Custom key-value data
  audience: [audience]
  workflow: [workflow-type]
```

**Extended fields (OpenCode/Claude Code extensions):**
```yaml
argument-hint: [args]                    # For slash command autocomplete
disable-model-invocation: false         # Prevent auto-trigger
user-invocable: true                    # Show in / menu
allowed-tools: [tools]                  # Tool restrictions
model: inherit                          # Model override
tags: [array]                           # Categorization
```

### Name Transformation

| Source | OpenCode |
|--------|----------|
| `hello_world` | `hello-world` |
| `HelloWorld` | `hello-world` |
| Mixed case | Lowercase hyphens only |

**Validation:** `^[a-z0-9]+(-[a-z0-9]+)*$`

### Description Transformation

**Format:** Third person, specific triggers, anti-triggers optional

```yaml
description: >
  [Skill name] for [domain]. This skill should be used when the user asks 
  to "[specific trigger 1]", "[specific trigger 2]", "[specific trigger 3]".
  [Optional anti-trigger: Do NOT use when...]
```

---

## Step 3: Structure the Skill

### OpenCode Skill Directory Structure

```
skill-name/
├── SKILL.md              # Required - frontmatter + core guidance
├── references/          # Optional - detailed documentation
│   ├── patterns.md     # Common patterns
│   └── advanced.md     # Advanced usage
├── scripts/            # Optional - executable utilities
│   └── validate.sh     # Make executable: chmod +x
├── examples/           # Optional - working examples
│   └── example.sh      # Complete, runnable
└── assets/             # Optional - templates, images
    └── template.md     # Output templates
```

### Progressive Disclosure Architecture

| Level | Content | When Loaded |
|-------|---------|------------|
| 1 | Frontmatter (`name` + `description`) | Always (~100 tokens) |
| 2 | SKILL.md body | On trigger (<5k words) |
| 3 | `references/`, `scripts/`, `examples/` | As needed |

**Rule:** SKILL.md should be 1,500-2,500 words. Move detailed content to `references/`.

---

## Step 4: Write the Content

### SKILL.md Writing Style

| Requirement | Correct | Incorrect |
|------------|---------|-----------|
| **Person** | Third person in description, imperative in body | Second person ("You should...") |
| **Tense** | Present | Past |
| **Voice** | Active | Passive |
| **Form** | Verb-first instructions | "You should..." |

**Example:**
```markdown
# Skill Name

[One paragraph overview]

## When to Use

Use this skill when:
- [Trigger 1]
- [Trigger 2]

Do NOT use this skill when:
- [Anti-trigger 1]

## Core Workflow

1. [Step 1]
2. [Step 2]
3. [Step 3]

## Additional Resources

### Reference Files
- **`references/patterns.md`** - [Description]

### Scripts
- **`scripts/validate.sh`** - [Description]
```

---

## Step 5: Validation Checklist

Before finalizing, verify:

### Frontmatter
- [ ] `name` matches directory and follows naming rules
- [ ] `description` uses third person with trigger phrases
- [ ] `description` is 1–1024 characters
- [ ] All used fields are valid OpenCode fields

### Structure
- [ ] SKILL.md exists with valid frontmatter
- [ ] Directory structure matches skill complexity
- [ ] All referenced files actually exist

### Content
- [ ] Body uses imperative form (not second person)
- [ ] Body is focused (1,500-2,500 words ideal)
- [ ] Detailed content in references/
- [ ] Examples are complete and runnable
- [ ] Scripts are executable

### Progressive Disclosure
- [ ] Core concepts in SKILL.md
- [ ] Detailed patterns in references/
- [ ] Working code in examples/
- [ ] Utilities in scripts/
- [ ] Resources referenced in SKILL.md

---

## Output Format

When given a skill to convert, produce:

1. **Analysis** — Brief summary of source skill structure
2. **OpenCode Structure** — The new directory layout
3. **SKILL.md** — The complete converted skill file
4. **Bundled Resources** — Any additional files (references/, scripts/, etc.)
5. **Validation** — Confirmation checklist

---

## Key Learnings from OpenCode Skill Development

### What Works
- Third-person descriptions with 5-10 specific trigger phrases
- Gerund form for skill names (`code-review`, `git-commit-writer`)
- Clear separation: SKILL.md for core, references/ for details
- Imperative form in body ("To accomplish X, do Y")
- Complete, runnable examples

### What Doesn't Work
- Vague trigger conditions ("Provides help with...")
- Everything in SKILL.md (>3,000 words)
- Second person writing ("You should...")
- Broken or incomplete examples
- Resources referenced but not created

### Frontmatter Fields That Matter
- `name` and `description` are the discovery mechanism
- `metadata` for custom categorization
- `license` for open source skills
- `compatibility` for multi-platform skills
- Extended fields for advanced control

### Progressive Disclosure is Essential
- Level 1 (metadata) loads always
- Level 2 (SKILL.md body) loads on trigger
- Level 3 (bundled resources) loads on demand
- Token efficiency requires keeping SKILL.md lean

---

## Agent Prompt Design

If the skill being converted involves creating agents, read this file before designing agent system prompts:

```
~/.config/opencode/prompts/agent-prompts-best-practices.md
```

---

For the most up-to-date information on OpenCode skills, consult these resources:

| Resource | URL | Purpose |
|----------|-----|---------|
| **Agent Skills Docs** | https://opencode.ai/docs/skills/ | Official skill documentation |
| **Skills Source** | `packages/opencode/src/skill/` | TypeScript implementation |
| **Agent Skills Spec** | https://agentskills.io | Open standard specification |
| **OpenCode GitHub** | https://github.com/anomalyco/opencode | Issue tracker, discussions |

**Key pages to check for updates:**
- Frontmatter field definitions
- Discovery path changes
- New optional fields
- Validation rules

**For skill development:**
- https://opencode.ai/docs/skills/ — Main skill docs
- https://opencode.ai/docs/agents/ — Agent system (related)
- https://opencode.ai/docs/plugins/ — Plugin development

---

## Example Transformation

**Source (Claude Code style):**
```yaml
---
name: my-skill
description: Helps with documentation tasks
---

# Documentation Helper

You should use this when user wants docs.

Steps:
1. Read the code
2. Write docs
3. Done.
```

**Target (OpenCode style):**
```yaml
---
name: documentation-helper
description: >
  Documentation helper for code projects. This skill should be used when 
  the user asks to "write documentation", "create README", "document this code",
  "add docstrings", or "generate API docs".
version: 0.1.0
license: MIT
compatibility: opencode
metadata:
  audience: developers
  domain: documentation
---

# Documentation Helper

Create clear, comprehensive documentation for code projects.

## When to Use

Use this skill when:
- User asks to write or update documentation
- Creating README files for new projects
- Documenting APIs or libraries
- Adding docstrings to code

Do NOT use this skill when:
- User wants real-time documentation in an IDE
- The task is just spelling/grammar checking

## Core Workflow

1. Analyze the code or project structure
2. Identify documentation needs
3. Write clear, accessible content
4. Format appropriately (markdown, JSDoc, etc.)

## Additional Resources

### Reference Files
- **`references/doc-types.md`** - Documentation types and standards

### Examples
- **`examples/readme-template.md`** - README template
```
