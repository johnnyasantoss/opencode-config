# Command Patterns

Common slash command patterns with working examples for OpenCode.

---

## Review Patterns

### Code Review Pattern

```markdown
---
description: Review recent changes
---

Files changed: !`git diff --name-only`

Review each file for:
1. Code quality and style
2. Potential bugs or issues
3. Test coverage
4. Documentation needs

Provide specific feedback for each file.
```

### Security Review Pattern

```markdown
---
description: Review code for security issues
argument-hint: [file-path]
---

Review @$1 for security vulnerabilities including:
- SQL injection
- XSS attacks
- Authentication bypass
- Insecure data handling

Provide specific line numbers and severity ratings.
```

### PR Review Pattern

```markdown
---
description: Review pull request
argument-hint: [pr-number]
---

PR #$1 Review:

1. Fetch PR: !`gh pr view $1 --json title,body,state,author`
2. Review changes: !`gh pr diff $1`
3. Run checks: !`gh pr checks $1`
4. Analyze and provide feedback
```

---

## Documentation Patterns

### Documentation Generation

```markdown
---
description: Generate documentation
argument-hint: [source-file]
---

Generate comprehensive documentation for @$1 including:
- Function/class descriptions
- Parameter documentation
- Return value descriptions
- Usage examples
- Edge cases and errors
```

### README Generation

```markdown
---
description: Generate README
argument-hint: [project-dir]
---

Analyze @$1 and generate a README including:
- Project description
- Installation instructions
- Usage examples
- Contributing guidelines
- License
```

---

## Workflow Patterns

### Complete PR Workflow

```markdown
---
description: Complete PR workflow
argument-hint: [pr-number]
---

PR #$1 Workflow:

1. Fetch: !`gh pr view $1`
2. Review: !`gh pr diff $1`
3. Checks: !`gh pr checks $1`
4. Approve or request changes with feedback
```

### Deploy Workflow

```markdown
---
description: Deploy application
argument-hint: [environment] [version]
---

Deploy application to $1 environment using version $2.
Monitor deployment and report status.
```

### Build Workflow

```markdown
---
description: Build project
argument-hint: [build-target]
---

Build target: $1

1. Install dependencies: !`npm install`
2. Run build: !`npm run build`
3. Verify output
4. Report build status
```

---

## Testing Patterns

### Run Tests

```markdown
---
description: Run tests for file
argument-hint: [test-file]
---

Run tests: !`npm test $1`

Analyze results and suggest fixes for any failures.
```

### Coverage Report

```markdown
---
description: Generate coverage report
argument-hint: [package-name]
---

Generate coverage report for $1:
!`npm test -- --coverage`

Review coverage metrics and identify untested code.
```

---

## File Patterns

### Multiple File Compare

```markdown
---
description: Compare two files
argument-hint: [old-file] [new-file]
---

Compare @src/$1 with @src/$2

Identify:
- Breaking changes
- New features
- Bug fixes
- Migration notes
```

### Config Validation

```markdown
---
description: Validate configuration
argument-hint: [config-file]
---

Load configuration: @$1

Validate:
- Required fields present
- Value formats correct
- Dependencies available
- Security settings appropriate
```

---

## Argument Handling Patterns

### Conditional Execution

```markdown
---
argument-hint: [file-path]
---

$IF($1,
  Process file: @$1,
  Please provide a file path. Usage: /process [file-path]
)
```

### Argument Validation

```markdown
---
description: Deploy with validation
argument-hint: [environment]
---

Validate environment: !`echo "$1" | grep -E "^(dev|staging|prod)$" || echo "INVALID"`

If $1 is valid environment:
  Deploy to $1
Otherwise:
  Explain valid environments: dev, staging, prod
  Show usage: /deploy [environment]
```

### File Existence Check

```markdown
---
description: Process configuration
argument-hint: [config-file]
---

Check file exists: !`test -f $1 && echo "EXISTS" || echo "MISSING"`

If file exists:
  Process configuration: @$1
Otherwise:
  Explain where to place config file
  Show expected format
  Provide example configuration
```

---

## Bash Execution Patterns

### Dynamic Context

```markdown
---
description: Show git status summary
---

Current branch: !`git branch --show-current`
Recent commits: !`git log --oneline -5`
Changed files: !`git diff --name-only`

Review changes and provide summary.
```

### Error Handling

```markdown
---
description: Build with error handling
---

Execute build: !`npm run build 2>&1 || echo "BUILD_FAILED"`

If build succeeded:
  Report success and output location
If build failed:
  Analyze error output
  Suggest likely causes
  Provide troubleshooting steps
```

---

## Best Practices Summary

1. **Single responsibility**: One command, one task
2. **Clear descriptions**: Self-explanatory in autocomplete
3. **Document arguments**: Use `argument-hint` for expected inputs
4. **Limit tool scope**: Use specific bash commands, not `Bash(*)`
5. **Handle errors**: Validate inputs, provide helpful messages
6. **Keep fast**: Long-running commands slow invocation
7. **Use agents**: Assign specialized agents when appropriate