# Frontmatter Field Reference

Complete specifications for YAML frontmatter fields in OpenCode slash commands.

## Available Fields

| Field | Type | Default | Purpose |
|-------|------|---------|---------|
| `description` | String | First line of prompt | Brief description shown in autocomplete |
| `agent` | String | Current agent | Specific agent to execute command |
| `model` | String | Current model | Specific model to use (format: provider/model) |
| `subtask` | Boolean | false | Force execution as subtask using Task tool |

---

## description

**Purpose:** Brief description shown in autocomplete

**Type:** String

**Default:** First line of command prompt

```yaml
---
description: Review pull request for code quality
---
```

**Best practices:**
- Keep clear and concise
- Use actionable language (verb-noun)
- Make self-explanatory without context

---

## agent

**Purpose:** Specify which agent should execute this command

**Type:** String

**Default:** Current agent

```yaml
---
agent: build
---
```

**When to use:**
- Command needs a specialized agent
- Command should run in a separate context (subtask)
- Workflow benefits from dedicated agent focus

```yaml
# Use specialized agent
agent: documentation-writer

# Use build agent
agent: build
```

---

## model

**Purpose:** Override the default model for this command

**Type:** String (format: provider/model)

**Default:** Current model

```yaml
---
model: anthropic/claude-3-5-sonnet-20241022
---
```

**Format:** `provider/model` as shown in `opencode models`

```yaml
# Anthropic model
model: anthropic/claude-3-5-sonnet-20241022

# OpenAI model
model: openai/gpt-4o

# Local model
model: ollama/llama3
```

---

## subtask

**Purpose:** Force command to execute as a subtask (uses Task tool)

**Type:** Boolean

**Default:** false

```yaml
---
subtask: true
---
```

**When to use:**
- Command should not pollute primary context
- Want agent to act as a subagent
- Complex background processing needed

```yaml
# Execute as subtask
subtask: true

# Execute in primary context (default)
subtask: false
```

---

## Field Combinations

### Documentation Command
```yaml
---
description: Generate API documentation
argument-hint: [source-file]
agent: documentation-writer
model: anthropic/claude-3-5-sonnet-20241022
---
```

### Review Command
```yaml
---
description: Review pull request
argument-hint: [pr-number]
agent: security-expert
---
```

### Fast Command
```yaml
---
description: Quick refactor
argument-hint: [file-path]
subtask: true
---
```