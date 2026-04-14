# If Condition Syntax

## Format

`ToolName(pattern)` where pattern supports `*` wildcard.

## Examples

| Condition | Matches |
|-----------|---------|
| `Bash(rm *)` | Bash commands starting with `rm` |
| `Edit(*.ts)` | Edit calls on `.ts` files |
| `Bash(sudo *)` | sudo commands |
| `Bash(rm *\|mv *)` | rm OR mv commands (pipe separator) |
| `Bash(*chmod *)` | chmod commands anywhere in args |

## Rules

- Tool names are case-insensitive: `Bash` matches `bash`, `Edit` matches `edit`
- `*` matches any sequence of characters (glob-style)
- Multiple patterns separated by `|` (pipe) act as OR
- Pattern matches against the tool's input text