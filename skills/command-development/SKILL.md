---
name: command-development
description: >
  Command development for OpenCode. This skill should be used when the user asks
  to "create a slash command", "add a command", "write a custom command", "define command
  arguments", "use command frontmatter", "organize commands", "create command with file
  references", or needs guidance on slash command structure, YAML frontmatter fields,
  dynamic arguments, bash execution in commands, or command development best practices.
version: 0.4.0
metadata:
  audience: developers
  domain: productivity
---

# Command Development

Create reusable slash commands that standardize workflows, automate prompts, and extend OpenCode capabilities.

## When to Use

Use this skill when:
- User asks to create, add, or write a slash command
- User needs guidance on command structure, frontmatter, or arguments
- User wants to make commands with dynamic inputs or file references
- User asks about organizing or namespacing commands
- User wants to execute bash commands within commands

Do NOT use this skill when:
- User is asking about agents (see Agent Development skill)
- User is building MCP servers (see MCP Integration skill)
- Task is simply invoking an existing command

## Command Basics

### What is a Slash Command?

A slash command is a Markdown file containing a prompt that OpenCode executes when invoked. Commands provide:
- **Reusability**: Define once, use repeatedly
- **Consistency**: Standardize common workflows
- **Sharing**: Distribute across team or projects
- **Efficiency**: Quick access to complex prompts

### Critical: Commands are Instructions FOR the Agent

Commands are written for agent consumption, not human consumption. When a user invokes `/command-name`, the command content becomes the agent's instructions.

**Correct approach (instructions for agent):**
```markdown
Review this code for security vulnerabilities including:
- SQL injection
- XSS attacks
- Authentication issues

Provide specific line numbers and severity ratings.
```

**Incorrect approach (messages to user):**
```markdown
This command will review your code for security issues.
```

Always write directives TO the agent about what to do.

## Command Locations

| Location | Scope | Label in autocomplete | Use Case |
|----------|-------|----------------------|----------|
| `.opencode/commands/` | Project | (project) | Team workflows |
| `~/.config/opencode/commands/` | User | (user) | Personal utilities |

## File Format

Commands are Markdown files with `.md` extension and optional YAML frontmatter.

**Simple command (no frontmatter):**
```markdown
Review this code for security vulnerabilities including:
- SQL injection
- XSS attacks
- Authentication bypass
```

**With YAML frontmatter:**
```markdown
---
description: Review code for security issues
agent: build
model: anthropic/claude-3-5-sonnet-20241022
---

Review this code for security vulnerabilities...
```

## Frontmatter Fields

| Field | Purpose | Type |
|-------|---------|------|
| `description` | Brief description shown in autocomplete | String |
| `agent` | Specific agent to execute command | String |
| `model` | Specific model to use | String |
| `subtask` | Force execution as subtask | Boolean |

See **[`reference/frontmatter.md`](./reference/frontmatter.md)** for complete field specifications.

## Dynamic Arguments

### Positional Arguments

Use `$1`, `$2`, `$3` for individual arguments:

```markdown
---
description: Review file with priority
argument-hint: [file-path] [priority]
---

Review @$1 with priority level $2.
```

**Usage:** `/review-file src/api/users.ts high`

### Remaining Arguments

Use `$ARGUMENTS` to capture all arguments as a single string:

```markdown
---
description: Ask the TypeScript expert
argument-hint: [question]
---

You are a TypeScript expert. Answer this question: $ARGUMENTS
```

## File References

### Using @ Syntax

Include file contents in command:

```markdown
---
description: Review component
argument-hint: [file-path]
---

Review the component in @$1.
Check for performance issues and suggest improvements.
```

**Usage:** `/review-component src/components/Button.tsx`

### Static References

Reference known files without arguments:

```markdown
Review @package.json and @tsconfig.json for consistency
```

## Bash Execution

Execute bash commands inline to gather dynamic context using `!`command`` syntax:

```markdown
---
description: Review recent changes
---

Recent git commits:
!`git log --oneline -10`

Review these changes and suggest any improvements.
```

**Best practices:**
- Avoid destructive operations
- Keep commands fast
- Test commands in terminal first

## Command Organization

### Flat Structure (5-15 commands)
```
.opencode/commands/
├── build.md
├── test.md
├── deploy.md
└── review.md
```

### Namespaced Structure (15+ commands)
```
~/.config/opencode/commands/
├── git/
│   ├── commit.md     # /git:commit → user:git:commit
│   └── pr.md        # /git:pr → user:git:pr
└── testing/
    └── unit.md      # /testing:unit → user:testing:unit
```

Subdirectories create nested command IDs with `user:` or `project:` prefix.

## JSON Config Alternative

Commands can also be defined in `opencode.json` instead of Markdown files:

```json
{
  "command": {
    "test": {
      "description": "Run tests with coverage",
      "template": "Run the full test suite with coverage report.",
      "agent": "build",
      "model": "anthropic/claude-3-5-sonnet-20241022"
    }
  }
}
```

## Common Patterns

### Review Pattern
```markdown
---
description: Review recent changes
---

Files changed: !`git diff --name-only`

Review each file for code quality, bugs, and test coverage.
```

### Documentation Pattern
```markdown
---
description: Generate documentation
argument-hint: [source-file]
---

Generate documentation for @$1 including descriptions, parameters, and examples.
```

### Workflow Pattern
```markdown
---
description: Complete PR workflow
argument-hint: [pr-number]
---

PR #$1 Workflow:
1. Fetch: !`gh pr view $1`
2. Review changes: !`gh pr diff $1`
3. Run checks: !`gh pr checks $1`
4. Approve or request changes
```

See **[`reference/patterns.md`](./reference/patterns.md)** for additional patterns and examples.

## Best Practices

1. **Single responsibility**: One command, one task
2. **Clear descriptions**: Self-explanatory in autocomplete
3. **Document arguments**: Use `argument-hint` for expected inputs
4. **Consistent naming**: Verb-noun pattern (review-file, fix-issue)
5. **Use agents**: Assign specialized agents to appropriate commands
6. **Be specific**: Be explicit in templates about what the agent should do

```markdown
---
description: Create a React component
argument-hint: [component-name]
---

Create a new React component named $ARGUMENTS with TypeScript support.
Include proper typing and basic structure.
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Command not appearing | Check directory, extension (.md), valid Markdown |
| Arguments not working | Verify `$1` syntax, check `argument-hint` matches |
| Bash failing | Ensure command syntax is correct with `!` prefix |
| File references not working | Verify `@` syntax, check file path |

## Additional Resources

### Reference Files
- **[`reference/frontmatter.md`](./reference/frontmatter.md)** - Complete frontmatter field reference
- **[`reference/patterns.md`](./reference/patterns.md)** - Common patterns and examples

### Official Documentation
- Commands docs: https://opencode.ai/docs/commands/
- CLI docs: https://opencode.ai/docs/cli/