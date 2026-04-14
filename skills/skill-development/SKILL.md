---
name: Skill Development
description: This skill should be used when the user wants to "create a skill", "add a skill", "write a new skill", "improve skill description", "organize skill content", or needs guidance on skill structure, progressive disclosure, or skill development best practices for OpenCode.
version: 0.2.0
---

# Skill Development for OpenCode

This skill provides comprehensive guidance for creating effective skills for OpenCode. Follow this process to create well-structured, discoverable skills that integrate seamlessly with OpenCode's skill system.

## Overview

Skills are modular, self-contained packages that extend OpenCode's capabilities by providing specialized knowledge, workflows, and tools. OpenCode implements the Agent Skills open standard, meaning skills created here work across Claude Code, VS Code, Cursor, Gemini CLI, and other compatible tools.

**Key concepts:**
- Skills are discovered via `SKILL.md` files in specific directories
- YAML frontmatter controls discovery and behavior
- Markdown body provides guidance content
- Optional bundled resources (scripts/, references/, assets/) enable progressive disclosure

---

## Part 1: Discovery Locations

OpenCode searches for skills in these locations (in priority order):

### Project-Local Paths
OpenCode walks up from your current working directory until it reaches the git worktree:

| Path | Description |
|------|-------------|
| `.opencode/skills/<name>/SKILL.md` | OpenCode native format |
| `.claude/skills/<name>/SKILL.md` | Claude Code compatible |
| `.agents/skills/<name>/SKILL.md` | Agent-compatible format |

### Global Paths

| Path | Description |
|------|-------------|
| `~/.config/opencode/skills/<name>/SKILL.md` | User-level skills |
| `~/.claude/skills/<name>/SKILL.md` | Claude Code user skills |
| `~/.agents/skills/<name>/SKILL.md` | Agent-compatible user skills |

**Note:** For OpenCode plugins, skills live in `plugins/<plugin-name>/skills/<skill-name>/SKILL.md`.

---

## Part 2: Frontmatter Fields

All possible fields for `SKILL.md` frontmatter:

### Required Fields

#### `name`
**Purpose:** Unique skill identifier
**Constraints:**
- 1–64 characters
- Lowercase alphanumeric with single hyphen separators
- Cannot start or end with `-`
- Cannot contain consecutive `--`
- Must match the directory name containing `SKILL.md`

**Valid pattern:** `^[a-z0-9]+(-[a-z0-9]+)*$`

```yaml
name: my-skill           # ✅ Valid
name: code-review        # ✅ Valid
name: MySkill            # ❌ Invalid - uppercase
name: my_skill           # ❌ Invalid - underscore
name: my--skill          # ❌ Invalid - consecutive hyphens
name: -my-skill          # ❌ Invalid - starts with hyphen
```

#### `description`
**Purpose:** Triggers skill discovery and explains purpose
**Constraints:** 1–1024 characters

**Best practice:** Use third-person format with specific trigger phrases:
```yaml
description: This skill should be used when the user asks to "create X", "add Y", "configure Z". Include exact phrases users would say that should trigger this skill.
```

**Quality indicators:**
- Includes specific trigger phrases (not just a summary)
- Explains when to use AND when NOT to use
- Uses third person ("This skill should be used when...")

---

### Standard Optional Fields

#### `license`
**Purpose:** License identifier for the skill content
**Type:** String (e.g., `MIT`, `Apache-2.0`, `AGPL-3.0`)

```yaml
license: MIT
```

#### `compatibility`
**Purpose:** Specify which agents/tools the skill is compatible with
**Type:** String (e.g., `opencode`, `claude`, `opencode, claude`)

```yaml
compatibility: opencode
```

#### `metadata`
**Purpose:** Custom key-value data for skill categorization/filtering
**Type:** Object with string values

```yaml
metadata:
  audience: maintainers
  workflow: github
  domain: security
  tier: premium
```

---

### Extended Fields (Claude Code / OpenCode Extensions)

These fields extend the base skill specification:

#### `version`
**Purpose:** Skill version for tracking changes
**Type:** String (e.g., `0.1.0`, `1.0.0`)

```yaml
version: 0.1.0
```

#### `argument-hint`
**Purpose:** Hint for slash command autocomplete
**Type:** String showing expected arguments

```yaml
argument-hint: [pr-number] [priority] [assignee]
```

#### `disable-model-invocation`
**Purpose:** Prevent Claude from automatically triggering this skill
**Type:** Boolean
**Default:** `false`

When `true`:
- Skill appears in `/help`
- User can invoke manually via `/skill-name`
- Claude cannot auto-load the skill

```yaml
disable-model-invocation: true
```

#### `user-invocable`
**Purpose:** Control whether skill appears in slash command menu
**Type:** Boolean
**Default:** `true`

When `false`:
- Hidden from `/` menu
- Claude can still auto-load if needed

```yaml
user-invocable: false
```

#### `allowed-tools`
**Purpose:** Restrict which tools the skill can use
**Type:** String or Array of tool names

```yaml
allowed-tools: Read, Grep, Glob          # Specific tools
allowed-tools: Bash(git:*)               # Bash with git commands only
allowed-tools: Read, Write, Bash          # Multiple tools
```

**Common tools:** `Read`, `Write`, `Edit`, `Bash`, `Grep`, `Glob`, `TodoWrite`, `Task`, `WebFetch`

#### `model`
**Purpose:** Override the model for skill execution
**Type:** String (`sonnet`, `opus`, `haiku`, `inherit`, or full model name)

```yaml
model: sonnet        # Use Sonnet for this skill
model: inherit       # Use parent's model (default)
```

#### `tags`
**Purpose:** Categorize skill for filtering/discovery
**Type:** Array of strings

```yaml
tags:
  - security
  - code-review
  - azure
```

#### `agent`
**Purpose:** Specify which agent type can use this skill
**Type:** String

```yaml
agent: Explore        # Read-only exploration agent
agent: Plan          # Planning agent
agent: general-purpose  # Full capabilities
```

#### `context`
**Purpose:** Control execution context
**Type:** String

```yaml
context: fork         # Run in isolated subagent context
```

#### `hooks`
**Purpose:** Define lifecycle hooks scoped to this skill
**Type:** Object

```yaml
hooks:
  PreToolUse: validate-input
  PostToolUse: log-action
  Stop: cleanup
```

---

## Part 3: Skill Structure

### Directory Format

```
skill-name/
├── SKILL.md              # Required (frontmatter + body)
├── references/           # Optional: detailed documentation
│   ├── patterns.md
│   └── advanced.md
├── scripts/              # Optional: executable utilities
│   └── validate.sh
├── examples/             # Optional: working examples
│   └── example.sh
└── assets/               # Optional: templates, images
    └── template.md
```

### Minimal Skill

```yaml
# skills/my-skill/SKILL.md
---
name: my-skill
description: This skill should be used when the user asks to "do X" or "handle Y".
---

# My Skill

Brief description of what this skill does.

## When to Use

Use this skill when:
- [Trigger scenario 1]
- [Trigger scenario 2]

## How to Use

[Core workflow]
```

### Complete Skill with Resources

```yaml
# skills/pdf-editor/SKILL.md
---
name: pdf-editor
description: This skill should be used when the user asks to "rotate a PDF", "merge PDFs", "split a PDF", "extract pages from PDF", or needs PDF manipulation help.
version: 0.1.0
metadata:
  category: document-processing
  audience: general
---

# PDF Editor Skill

This skill provides guidance for PDF manipulation tasks.

## Overview

[Core concepts and procedures]

## Common Operations

[Most frequent use cases]

## Additional Resources

### Reference Files
- **`references/rotate.md`** - Detailed rotation patterns
- **`references/merge.md`** - Merging strategies

### Scripts
- **`scripts/rotate_pdf.py`** - PDF rotation utility

### Examples
- **`examples/batch-rotate.sh`** - Batch rotation example
```

---

## Part 4: Creating a Skill — Interactive Process

Follow these steps to create the best possible skill:

### Step 1: Understand the Skill's Purpose

Before writing anything, gather information by asking the user:

**Essential Questions:**

1. **What is the skill's primary purpose?**
   - What domain or task does it cover?
   - What problem does it solve?

2. **Who is the target audience?**
   - Developers working on specific frameworks?
   - DevOps engineers?
   - Security auditors?

3. **What trigger phrases should activate this skill?**
   - List 5-10 specific phrases users would say
   - Include variations (formal, informal, common mistakes)
   - Include anti-triggers (when NOT to use)

4. **What resources does this skill need?**
   - Scripts/utilities for deterministic operations?
   - Reference documentation for complex APIs?
   - Example templates for output?

5. **Are there similar existing skills?**
   - Should this integrate with other skills?
   - Any naming conflicts to avoid?

### Step 2: Plan the Skill Structure

Based on Step 1, determine:

**Core Decision: What type of skill?**

| Type | Structure | Use When |
|------|-----------|----------|
| **Knowledge** | Just SKILL.md | Simple guidance, no complex resources |
| **Procedural** | SKILL.md + references/ | Multi-step workflows |
| **Tool-Based** | SKILL.md + scripts/ | Deterministic operations |
| **Template-Based** | SKILL.md + assets/ | Output generation |
| **Comprehensive** | All of the above | Complex domains |

### Step 3: Create the Skill Directory

**For user/global skills:**
```bash
mkdir -p ~/.config/opencode/skills/<skill-name>
touch ~/.config/opencode/skills/<skill-name>/SKILL.md
```

**For project-local skills:**
```bash
mkdir -p .opencode/skills/<skill-name>
touch .opencode/skills/<skill-name>/SKILL.md
```

**For plugin skills:**
```bash
mkdir -p plugins/<plugin-name>/skills/<skill-name>
touch plugins/<plugin-name>/skills/<skill-name>/SKILL.md
```

### Step 4: Write the Frontmatter

Complete all applicable frontmatter fields:

```yaml
---
name: [skill-name]
description: [Trigger phrases in third person]
version: 0.1.0
license: [License if applicable]
compatibility: opencode
metadata:
  [key]: [value]
# Extended fields if needed:
# argument-hint: [args]
# disable-model-invocation: false
# allowed-tools: [tools]
# model: inherit
# tags: []
---
```

### Step 5: Write the SKILL.md Body

**Writing Style Requirements:**

| Requirement | Correct | Incorrect |
|-------------|---------|-----------|
| **Person** | Third person in description, imperative in body | Second person |
| **Tense** | Present tense | Past tense |
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

## Reference

For detailed patterns, see:
- **`references/patterns.md`** - Common patterns
- **`references/advanced.md`** - Advanced usage
```

### Step 6: Create Bundled Resources

**references/ — Documentation loaded on demand:**
```bash
mkdir -p skills/<skill-name>/references
# Add detailed docs, schemas, API references
```

**scripts/ — Executable utilities:**
```bash
mkdir -p skills/<skill-name>/scripts
# Add deterministic scripts (Python, Bash, etc.)
# Make executable: chmod +x scripts/name.sh
```

**examples/ — Working code examples:**
```bash
mkdir -p skills/<skill-name>/examples
# Add complete, runnable examples
```

**assets/ — Templates and static files:**
```bash
mkdir -p skills/<skill-name>/assets
# Add templates, images, boilerplate
```

---

## Part 5: Validation Checklist

Before finalizing a skill:

### Frontmatter
- [ ] `name` matches directory and follows naming rules
- [ ] `description` uses third person with trigger phrases
- [ ] `description` is 1–1024 characters
- [ ] All used fields are documented in this skill

### Structure
- [ ] SKILL.md exists with valid frontmatter
- [ ] Directory structure matches skill type
- [ ] All referenced files exist

### Content
- [ ] Body uses imperative/infinitive form
- [ ] Body is focused (1500-2500 words ideal)
- [ ] Detailed content moved to references/
- [ ] Examples are complete and runnable
- [ ] Scripts are executable

### Progressive Disclosure
- [ ] Core concepts in SKILL.md
- [ ] Detailed patterns in references/
- [ ] Working code in examples/
- [ ] Utilities in scripts/
- [ ] Resources referenced in SKILL.md

### Discovery
- [ ] Skill in correct location for target use
- [ ] Name unique across all locations
- [ ] Triggers are specific and testable

---

## Part 6: Frontmatter Field Reference

### All Recognized Fields

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `name` | **Yes** | string | Unique identifier (1-64 chars, lowercase + hyphens) |
| `description` | **Yes** | string | Trigger description (1-1024 chars) |
| `license` | No | string | License identifier (MIT, Apache-2.0, etc.) |
| `compatibility` | No | string | Agent compatibility (opencode, claude) |
| `metadata` | No | object | Custom key-value data |
| `version` | No | string | Skill version |
| `argument-hint` | No | string | Autocomplete hint for `/` commands |
| `disable-model-invocation` | No | boolean | Prevent auto-trigger (default: false) |
| `user-invocable` | No | boolean | Show in `/` menu (default: true) |
| `allowed-tools` | No | string/array | Permitted tools |
| `model` | No | string | Model override |
| `tags` | No | array | Categorization tags |
| `agent` | No | string | Agent type restriction |
| `context` | No | string | Execution context |
| `hooks` | No | object | Lifecycle hooks |

### Field Interactions

| Configuration | Manual Invoke (`/`) | Auto-Trigger | In Context |
|---------------|---------------------|---------------|------------|
| Default | ✅ | ✅ | ✅ |
| `disable-model-invocation: true` | ✅ | ❌ | ❌ |
| `user-invocable: false` | ❌ | ✅ | ✅ |

### Unknown Fields

Unknown frontmatter fields are **ignored** by OpenCode. Use `metadata` for custom data.

---

## Part 7: Best Practices Summary

### ✅ DO

- Use third person in description ("This skill should be used when...")
- Include 5-10 specific trigger phrases
- Add anti-triggers (when NOT to use)
- Keep SKILL.md lean (1500-2500 words)
- Use progressive disclosure for detailed content
- Write in imperative form in body
- Reference all bundled resources
- Provide complete, runnable examples
- Create utility scripts for repeated operations
- Test triggers manually before finalizing

### ❌ DON'T

- Use second person in description or body
- Have vague trigger conditions
- Put everything in SKILL.md (>3000 words)
- Include broken or incomplete examples
- Skip validation of trigger phrases
- Leave resources unreferenced
- Use uppercase in name field
- Include special characters except single hyphens

---

## Part 8: Examples

### Minimal Example
```yaml
---
name: hello-world
description: This skill should be used when the user asks to "say hello" or "test a skill".
---

# Hello World Skill

A simple skill for demonstration purposes.

## When to Use

- User wants a greeting
- Testing skill discovery

## Usage

Simply invoke: `/hello-world`
```

### Full Example
```yaml
---
name: git-release
description: This skill should be used when the user asks to "create a release", "draft release notes", "prepare a version bump", or "tag a release". Provides consistent release workflows with changelog generation.
version: 1.0.0
license: MIT
compatibility: opencode, claude
metadata:
  audience: maintainers
  workflow: github
---

# Git Release Skill

Standardized release workflow for GitHub projects.

## When to Use

Use this skill when:
- Preparing a tagged release
- Drafting changelog entries
- Version bumping

Do NOT use this skill when:
- Doing hotfixes (use `git-hotfix` skill instead)
- Just committing code (use `git-commit` skill)

## Workflow

1. Identify version bump type (major/minor/patch)
2. Collect commits since last release
3. Draft changelog entries
4. Create git tag
5. Generate `gh release create` command

## Reference Files

- **`references/versioning.md`** - Semantic versioning guide
- **`references/changelog-format.md`** - Changelog format standards

## Scripts

- **`scripts/draft-changelog.sh`** - Generate changelog from commits
```

---

## Part 8: Agent Prompt Best Practices

When creating skills that involve agent prompt design, read this file for established patterns:

```
~/.config/opencode/prompts/agent-prompts-best-practices.md
```

---

## Quick Reference

### Name Validation
```
Regex: ^[a-z0-9]+(-[a-z0-9]+)*$
Length: 1-64 characters
Format: lowercase, hyphens only
```

### Description Length
```
Min: 1 character
Max: 1024 characters
```

### Discovery Paths (Priority Order)
```
1. .opencode/skills/<name>/SKILL.md
2. .claude/skills/<name>/SKILL.md
3. .agents/skills/<name>/SKILL.md
4. ~/.config/opencode/skills/<name>/SKILL.md
5. ~/.claude/skills/<name>/SKILL.md
6. ~/.agents/skills/<name>/SKILL.md
```

### Resource Directories
```
references/  — Documentation loaded on demand
scripts/     — Executable utilities
examples/    — Working code examples  
assets/      — Templates and static files
```
