---
name: Agent Creator
description: This skill should be used when the user asks to "create an agent", "add an agent", "write a subagent", "agent frontmatter", "when to use description", "agent examples", "agent tools", "agent colors", "autonomous agent", or needs guidance on agent structure, triggering conditions, or agent development best practices for OpenCode.
version: 0.3.0
---

# Agent Development for OpenCode

This skill provides comprehensive guidance for creating effective agents for OpenCode. Agents are autonomous subprocesses that handle complex, multi-step tasks independently. Understanding agent structure, triggering conditions, system prompt design, and permission configuration enables creating powerful autonomous capabilities.

## Overview

**Key concepts:**
- **Agents vs Commands**: Agents are FOR autonomous work; commands are FOR user-initiated actions
- **Markdown format**: Agents use YAML frontmatter + markdown body
- **Filename as identifier**: The filename (without `.md`) becomes the agent name
- **Mode-based invocation**: Primary agents via Tab/switching; subagents via `@mention`
- **Permission system**: Controls tool access (`edit`, `bash`, `webfetch`, `skill`, `task`)

---

## Part 1: Agent Types

### Primary Agents

Primary agents are the main assistants you interact with directly.

**Invocation:**
- Press **Tab** to cycle through primary agents
- Use `switch_agent` keybind for custom binding

**Use cases:**
- `build` - Default development agent with all tools enabled
- `plan` - Read-only planning and analysis
- Custom primary agents for specific workflows

### Subagents

Subagents are specialized assistants invoked for specific tasks.

**Invocation:**
- **@mention** in messages: `@general help me search for this`
- Automatically invoked by other agents based on description

**Use cases:**
- `general` - Multi-step task execution with full tool access
- `explore` - Fast read-only codebase exploration
- Custom subagents for domain-specific tasks

### Built-in Agents

| Agent | Mode | Purpose | Default Permissions |
|-------|------|---------|---------------------|
| `build` | primary | Default development agent | All tools allowed |
| `plan` | primary | Planning and analysis (read-only) | edit/bash: ask |
| `general` | subagent | Multi-step autonomous tasks | All except TodoWrite |
| `explore` | subagent | Fast codebase exploration | Read-only |
| `compaction` | primary | Context summarization (hidden) | Auto-triggered |
| `title` | primary | Session titling (hidden) | Auto-triggered |
| `summary` | primary | Session summary (hidden) | Auto-triggered |

---

## Part 2: Discovery Locations

OpenCode discovers agents from markdown files in these locations:

### Global Paths
```
~/.config/opencode/agents/<name>.md
~/.opencode/agents/<name>.md
```

### Project Paths
```
.opencode/agents/<name>.md
```

### Config-Based (opencode.json)
Agents can also be configured directly in `opencode.json` under the `agent` key.

**Note:** The filename becomes the agent identifier. For example, `review.md` creates a `review` agent.

---

## Part 3: Frontmatter Fields

### Complete Field Reference

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `description` | **Yes** | string | When to use this agent (1-5000 chars) |
| `mode` | No | enum | `primary`, `subagent`, `all` (default: `all`) |
| `model` | No | string | Model override (`provider/model-id` format) |
| `temperature` | No | number | Randomness control (0.0-1.0) |
| `top_p` | No | number | Alternative to temperature (0.0-1.0) |
| `steps` | No | number | Max agentic iterations before text-only |
| `permission` | No | object | Tool permissions (`ask`, `allow`, `deny`) |
| `color` | No | string | Hex color (`#FF5733`) or theme color |
| `hidden` | No | boolean | Hide from `@` autocomplete |
| `disable` | No | boolean | Disable this agent entirely |
| `prompt` | No | string | Custom prompt file path |
| `options` | No | object | Provider-specific options |
| `variant` | No | string | Model variant (with `model`) |
| `name` | No | string | Override agent name (usually filename is used) |

---

### Field Details

#### `description` (Required)

Defines when OpenCode should trigger this agent. **This is the most critical field.**

```yaml
description: Reviews code for security vulnerabilities. Use when:
- User asks to review code for security issues
- Auditing authentication or authorization
- Checking for common vulnerabilities (SQL injection, XSS, etc.)
```

**Best practices:**
- Use third-person format ("This agent should be used when...")
- Include specific triggering conditions
- List different use cases
- Explain when NOT to use the agent (anti-triggers)

#### `mode`

Controls how the agent can be used.

```yaml
mode: subagent   # Invoked via @mention or by other agents
mode: primary    # Main agent (Tab to switch)
mode: all        # Default - can be used both ways
```

#### `model`

Override the model for this agent.

```yaml
model: anthropic/claude-sonnet-4-20250514
model: openrouter/anthropic/claude-sonnet-4
model: inherit   # Use parent's model (recommended for subagents)
```

**Format:** `provider/model-id`

**Best practice:** Use `inherit` for subagents to maintain context with parent.

#### `permission`

Manage what actions an agent can take.

```yaml
permission:
  edit: deny          # All edits denied
  bash: ask           # Bash requires approval
  webfetch: deny      # No web fetching
  skill:
    "*": deny
    "code-review": allow
  task:
    "*": deny
    "explore": allow
```

**Permission levels:**
- `ask` — Prompt for approval before running
- `allow` — Allow without approval
- `deny` — Disable the tool entirely

**Bash glob patterns:**
```yaml
permission:
  bash:
    "*": ask              # Default: ask for all
    "git status *": allow
    "git diff *": allow
    "grep *": allow
    "rm *": deny          # Never allow deletion
```

**Task permissions** (controlling subagent invocation):
```yaml
permission:
  task:
    "*": deny             # No subagent invocation
    "explore": allow      # Only explore subagent
    "code-review-*": ask  # Ask for code-review agents
```

#### `steps`

Control maximum agentic iterations before forced text response.

```yaml
steps: 5    # After 5 iterations, respond with text summary
```

**Use when:** You want to limit autonomous behavior for cost control.

#### `temperature`

Control randomness (0.0-1.0).

```yaml
temperature: 0.3   # Balanced creativity
temperature: 0.1   # Focused, deterministic
temperature: 0.7   # Creative, varied
```

**Guidelines:**
- 0.0-0.2: Code analysis, planning, precise tasks
- 0.3-0.5: General development
- 0.6-1.0: Brainstorming, creative work

**Default:** 0 for most models, 0.55 for Qwen models

#### `top_p`

Alternative to temperature for controlling randomness.

```yaml
top_p: 0.9
```

#### `color`

Customize visual appearance in UI.

```yaml
color: "#FF5733"           # Hex color
color: "accent"            # Theme color
```

**Theme colors:** `primary`, `secondary`, `accent`, `success`, `warning`, `error`, `info`

#### `hidden`

Hide from `@` autocomplete menu.

```yaml
hidden: true
```

**Use when:** Internal subagent only invoked programmatically by other agents.

#### `disable`

Disable agent entirely.

```yaml
disable: true
```

#### `prompt`

Specify custom system prompt file.

```yaml
prompt: "{file:./prompts/my-agent.txt}"
```

#### `options`

Provider-specific options passed directly to the model.

```yaml
options:
  reasoningEffort: "high"    # OpenAI reasoning models
  textVerbosity: "low"       # Model-specific options
```

---

## Part 4: System Prompt Design

The markdown body becomes the agent's system prompt. Write in **second person**, addressing the agent directly.

### Standard Template

```markdown
You are [role] specializing in [domain].

**Your Core Responsibilities:**
1. [Primary responsibility]
2. [Secondary responsibility]
3. [Additional responsibilities...]

**Analysis Process:**
1. [Step one]
2. [Step two]
3. [Step three]
[...]

**Quality Standards:**
- [Standard 1]
- [Standard 2]

**Output Format:**
Provide results in this format:
- [What to include]
- [How to structure]

**Edge Cases:**
Handle these situations:
- [Edge case 1]: [How to handle]
- [Edge case 2]: [How to handle]
```

### Writing Style

| Requirement | Correct | Incorrect |
|-------------|---------|-----------|
| **Person** | Second person ("You are...") | First person ("I am...") |
| **Tense** | Present tense | Past tense |
| **Voice** | Active | Passive |
| **Structure** | Clear sections with headers | Wall of text |

### Best Practices

✅ **DO:**
- Write in second person ("You are...", "You will...")
- Be specific about responsibilities
- Provide step-by-step process
- Define output format clearly
- Include quality standards
- Address edge cases
- Keep under 10,000 characters

❌ **DON'T:**
- Write in first person ("I am...", "I will...")
- Be vague or generic
- Omit process steps
- Leave output format undefined
- Skip quality guidance
- Ignore error cases

---

## Part 5: Creating an Agent — Interactive Process

Follow these steps to create the best possible agent:

### Step 1: Understand the Agent's Purpose

**Essential Questions to Ask the User:**

1. **What is the agent's primary function?**
   - What domain or task?
   - What problem does it solve?

2. **Who will use this agent?**
   - Primary agent for direct interaction?
   - Subagent invoked by other agents?

3. **What trigger phrases should activate this agent?**
   - List 5-10 specific phrases
   - Include anti-triggers (when NOT to use)

4. **What tools should this agent have access to?**
   - Read-only (explore, analyze)?
   - Full development (edit, bash)?
   - Specific tools only?

5. **Should this agent be visible or hidden?**
   - Visible: User invokes via `@mention`
   - Hidden: Only invoked programmatically

6. **Any model preferences?**
   - Specific model for this task?
   - Inherit from parent?

### Step 2: Plan the Agent Configuration

Based on answers, determine:

| Decision | Options |
|----------|---------|
| **Mode** | `primary`, `subagent`, `all` |
| **Tools** | Full access, read-only, or specific subset |
| **Model** | `inherit`, specific model, or default |
| **Limits** | Steps limit, temperature, color |

### Step 3: Create the Agent File

**For markdown-based agents:**

```bash
# Global location
touch ~/.config/opencode/agents/<agent-name>.md

# Project location
touch .opencode/agents/<agent-name>.md
```

**Or use the CLI:**
```bash
opencode agent create
```

This interactive command will:
1. Ask where to save (global or project)
2. Ask for agent description
3. Generate system prompt and identifier
4. Select tool permissions
5. Create the markdown file

### Step 4: Write the Frontmatter

```yaml
---
description: This agent should be used when [triggering conditions].
mode: subagent
model: inherit
permission:
  edit: deny
  bash: ask
  webfetch: deny
color: "#00FFFF"
steps: 10
---
```

### Step 5: Write the System Prompt

```markdown
You are [role description].

**Your Core Responsibilities:**
1. [Responsibility 1]
2. [Responsibility 2]
3. [Responsibility 3]

**Analysis Process:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Output Format:**
[Define expected output structure]

**Edge Cases:**
- [Edge case 1]: [Handling approach]
- [Edge case 2]: [Handling approach]
```

---

## Part 6: Permission Patterns

### Read-Only Agent

```yaml
permission:
  edit: deny
  bash: deny
  webfetch: deny
```

### Analysis Agent

```yaml
permission:
  edit: deny
  bash:
    "*": ask
    "git diff *": allow
    "git log *": allow
    "grep *": allow
    "rg *": allow
```

### Development Agent

```yaml
permission:
  edit: allow
  bash:
    "*": ask
    "git add *": allow
    "git commit *": allow
    "npm *": allow
    "cargo *": allow
```

### Orchestrator Agent (with subagent control)

```yaml
permission:
  edit: allow
  bash: allow
  task:
    "*": deny
    "explore": allow
    "code-review-*": allow
```

---

## Part 7: Validation Rules

### Identifier (Filename) Validation

```
✅ Valid: code-reviewer.md, test-gen.md, api-analyzer-v2.md
❌ Invalid: Same name as built-in (build, plan, general, explore)
❌ Invalid: Reserved names (session_child*, compaction, title, summary)
```

### Description Validation

- **Length:** 10-5,000 characters
- **Must include:** Triggering conditions
- **Best:** 100-500 characters with specific phrases

### System Prompt Validation

- **Length:** 20-10,000 characters
- **Best:** 500-3,000 characters
- **Structure:** Clear responsibilities, process, output format

---

## Part 8: Invocation and Navigation

### Primary Agents

| Action | Method |
|--------|--------|
| Switch agents | Press **Tab** or `switch_agent` keybind |
| View available | Show in agent selector UI |

### Subagents

| Action | Method |
|--------|--------|
| Invoke | `@agentname` in message |
| Auto-invoke | Based on description matching |

### Session Navigation

When subagents create child sessions:

| Action | Default Keybind |
|--------|-----------------|
| Enter first child | `Leader+Down` |
| Cycle to next child | `Right` |
| Cycle to previous child | `Left` |
| Return to parent | `Up` |

---

## Part 9: Complete Examples

### Documentation Agent

```markdown
---
description: Writes and maintains project documentation. Use when:
- User asks to create or update README files
- Documentation needs to be written for new features
- User requests API documentation
- User says "document this", "write docs", "create README"
mode: subagent
permission:
  edit: allow
  bash: deny
  webfetch: deny
color: "#4CAF50"
---

You are a technical writer. Create clear, comprehensive documentation.

**Your Core Responsibilities:**
1. Write and update README files
2. Create API documentation
3. Maintain project documentation
4. Add docstrings to code

**Analysis Process:**
1. Understand the feature or code being documented
2. Identify target audience
3. Structure documentation appropriately
4. Write clear, concise content with examples

**Output Format:**
- Clear headings and structure
- Code examples where applicable
- Proper markdown formatting

**Quality Standards:**
- Use simple, accessible language
- Include practical examples
- Follow documentation best practices
```

### Security Auditor

```markdown
---
description: Performs security audits and identifies vulnerabilities. Use when:
- User asks to review code for security issues
- Auditing authentication or authorization
- Checking for common vulnerabilities (SQL injection, XSS, CSRF)
- User says "security audit", "check for vulnerabilities", "security review"
mode: subagent
permission:
  edit: deny
  bash:
    "*": ask
    "grep *": allow
    "rg *": allow
color: "#F44336"
steps: 15
---

You are a security expert. Identify potential security issues in code.

**Your Core Responsibilities:**
1. Identify input validation vulnerabilities
2. Check authentication and authorization
3. Detect data exposure risks
4. Find dependency vulnerabilities
5. Review configuration security

**Analysis Process:**
1. Review code for user input handling
2. Check authentication mechanisms
3. Analyze authorization checks
4. Look for sensitive data exposure
5. Review dependency usage

**Output Format:**
Provide findings in this structure:
- **Issue**: [Description]
- **Severity**: [Critical/High/Medium/Low]
- **Location**: [File:line]
- **Recommendation**: [Fix approach]

**Look For:**
- SQL injection vulnerabilities
- Cross-site scripting (XSS)
- CSRF vulnerabilities
- Insecure authentication
- Missing authorization checks
- Hardcoded credentials
- Insecure dependencies
```

### Orchestrator Agent

```markdown
---
description: Coordinates complex multi-agent workflows. Use when:
- User has a complex project requiring multiple specialized agents
- Task involves coordinating research, implementation, and review
- User says "handle this project", "manage the workflow", "coordinate agents"
mode: primary
permission:
  task:
    "*": deny
    "explore": allow
    "code-review": allow
    "debugger": allow
color: "#9C27B0"
steps: 20
---

You are an orchestrator agent. Coordinate multiple specialized agents to complete complex projects.

**Your Core Responsibilities:**
1. Break down complex tasks into subtasks
2. Delegate to appropriate specialized agents
3. Synthesize results from subagents
4. Ensure coherent final output

**Analysis Process:**
1. Analyze the overall task
2. Identify specialized subtasks
3. Invoke appropriate subagents
4. Monitor subagent progress
5. Integrate results

**Subagent Coordination:**
- Use `@explore` for research and discovery
- Use `@code-review` for review tasks
- Use `@debugger` for investigation tasks

**Output Format:**
- Summary of coordinated work
- Individual agent results
- Final integrated solution
```

---

## Part 10: Agent Prompt Best Practices

When creating agents, read this file for established patterns:

```
~/.config/opencode/prompts/agent-prompts-best-practices.md
```

---

## Part 11: Quick Reference

### Agent Discovery Paths

```
Global:  ~/.config/opencode/agents/<name>.md
Project: .opencode/agents/<name>.md
Config:  opencode.json → agent.<name>
```

### Mode Types

| Mode | User Invoke | Agent Invoke | Tab Switch |
|------|-------------|-------------|------------|
| `primary` | Via @mention | Via Task | ✅ |
| `subagent` | Via @mention | Via Task | ❌ |
| `all` | Both | Both | ✅ |

### Permission Levels

| Level | Behavior |
|-------|----------|
| `allow` | Execute without approval |
| `ask` | Prompt for approval |
| `deny` | Tool disabled |

### Frontmatter Summary

```yaml
---
description: [Required - trigger conditions]
mode: primary|subagent|all
model: provider/model-id|inherit
temperature: 0.0-1.0
top_p: 0.0-1.0
steps: [number]
permission:
  edit: ask|allow|deny
  bash: ask|allow|deny|{pattern: level}
  webfetch: ask|allow|deny
  skill: {pattern: level}
  task: {pattern: level}
color: "#hex"|theme-color
hidden: true|false
disable: true|false
prompt: "{file:path}"
---
```
