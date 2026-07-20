---
description: Commit changes in session
agent: git-master
subtask: false
---

Commit changes made in this session in an atomic manner.

## Rules
Titles must be descriptive and concise while following conventional commit format.
Follow repository contribution guidelines.
Commit descriptions must:
- Be concise
- Add decision context as a standalone prose
- Explain why the change was made, not just what was changed
- If relevant, add in test results/benchmarks/info that was relevant for the decision that led to the commit
- Avoid replicating deliberation process entirely. Focus solely on information that is not obvious (elsewhere in commit contents)

Current changes:
```bash
# git status --porcelain=v1
!`git status --porcelain=v1`
```
