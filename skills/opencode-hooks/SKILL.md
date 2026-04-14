---
name: opencode-hooks
version: 0.1.0
description: >
  Configure and manage hooks in OpenCode. This skill should be used when the user
  asks to "configure hooks", "block commands", "set up PreToolUse", "add PostToolUse
  hook", "create hooks.json", "block dangerous commands", "enforce policies",
  "audit tool usage", "log tool calls", or "set up hook conditions".
  Do NOT use when the user asks about git hooks, webhooks, or React hooks.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  domain: security
  workflow: configuration
---

# OpenCode Hooks

Configure hooks that intercept OpenCode tool events to block dangerous commands, log usage, and enforce policies.

## When to Use

Use this skill when:
- Blocking dangerous bash commands (rm, sudo, etc.)
- Logging or auditing Edit/Write tool calls
- Enforcing coding policies via PreToolUse hooks
- Creating or modifying `hooks.json` files
- Debugging hooks that aren't firing

## Non-Negotiable Rules

1. Read `hooks.json` from known search paths before assuming policies
2. Use `error` field for simple blocking — no process spawning needed
3. Use `if` conditions to target specific tool arguments
4. PreToolUse blocks — the action is denied before execution
5. PostToolUse does not block — action already completed, only for logging

## Core Workflow

1. Identify the event type (PreToolUse for blocking, PostToolUse for logging)
2. Set the `matcher` to the tool name (case-insensitive)
3. Add `if` condition to narrow matches, or leave broad for all calls
4. Use `error` field for direct blocking, or `command` for scripts

### Quick Example

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(rm *)",
            "error": "rm commands are not allowed"
          }
        ]
      }
    ]
  }
}
```

## Event Mapping

| Hook Event | OpenCode Event | Blocks? |
|------------|----------------|---------|
| PreToolUse | tool.execute.before | Yes |
| PostToolUse | tool.execute.after | No |
| SessionStart | session.created | Maybe |
| SessionEnd | session.deleted | Maybe |
| Stop | session.idle | Maybe |

Session events may not fire in headless/CLI mode.

## Tool Name Reference

| OpenCode Tool | if Condition |
|--------------|-------------|
| bash | Bash(command) |
| edit | Edit(file_path) |
| write | Write(file_path) |
| read | Read(file_path) |
| glob | Glob(pattern) |
| grep | Grep(pattern) |

## Troubleshooting

- Set `OPENCODE_HOOKS_DEBUG=true` for verbose output
- Ensure `matcher` matches lowercase tool name
- PreToolUse conditions are checked before tool runs
- Use `type: "command"` and `error` field for direct blocking
- Exit code 2 from a script also blocks

## Additional Resources

### Reference Files
- **`references/if-conditions.md`** - If condition syntax and pattern matching
- **`references/patterns.md`** - Blocking and logging patterns with examples

### Config Search Paths
- `.opencode/hooks.json` (project-level, highest priority)
- `~/.config/opencode/hooks.json` (global)
- `.claude/settings.json` (Claude Code compatibility)