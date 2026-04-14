# Hook Patterns

## Simple Blocking (Preferred)

Use the `error` field for direct blocking without a script:

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
            "error": "rm commands are blocked"
          }
        ]
      }
    ]
  }
}
```

## Multiple Dangerous Patterns

Combine patterns with `|` to match any of them:

```json
{
  "type": "command",
  "if": "Bash(rm *|mv *|*chmod *)",
  "error": "Destructive commands are not allowed"
}
```

## Logging/Auditing

PostToolUse fires after tool success — use for logging:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": ["/path/to/log-edit.sh"]
          }
        ]
      }
    ]
  }
}
```

## Broad Matcher Without If

Match all calls to a tool (no `if` condition):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "error": "Write tool is disabled"
          }
        ]
      }
    ]
  }
}
```

## Script-Based Blocking

Use a command script that exits with code 2 to block:

```json
{
  "type": "command",
  "command": ["/path/to/check.sh"],
  "if": "Bash(*)"
}
```

The script receives tool input as JSON on stdin. Exit code 2 blocks the action; exit code 0 allows it.