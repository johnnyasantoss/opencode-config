# opencode-config

Personal [OpenCode](https://github.com/anomalyco/opencode) configuration for
open-weight and locally-hosted models. Not a framework, just config files that
evolved from daily use.

## What this is

This repo contains my OpenCode setup. The focus is routing to local inference
engines and open-weight models rather than proprietary APIs.

Models run through:
- [LM Studio](https://lmstudio.ai/)
- OpenRouter
- OpenCode Go
- Ollama
- [LlamaBarn](https://github.com/JohnnyASantos/llamabarn)

### Notes

This configuration uses restrained permissions by default. Agents have restricted
tool access: the orchestrator cannot edit files directly, bash commands require
explicit approval, and destructive operations are gated. The intent is to force
proper delegation to specialized agents and reduce accidental damage. You may find
this conservative approach works better than fully permissive defaults.

## Files

- `opencode.json`: Main config. Provider definitions, agent model routing (general, explore, build, plan, orchestrator, researcher, review, git-master), permissions, MCP server setup, plugin list, server settings (CORS, mDNS, port 4096).
- `AGENTS.md`: Global rules that all agents inherit (110 lines). Task management, code style, git conventions, terminal behavior, security, error handling.
- `prompts/`: Shared prompt templates: `agent-prompts-best-practices.md`, `fullplan.md`.
- `vibeguard.config.json`: PII redaction config: builtin patterns (email, phone, UUID, IPv4, MAC) + custom regexes (API keys, GitHub tokens, AWS keys).

## Agents

Custom agents live in `agents/` with YAML frontmatter. Each has a specific
role and restricted permissions:

- `orchestrator.md`: Coordinates multi-phase tasks. Routes work to other
  agents. Cannot edit files or run commands directly. Model: deepseek-v4-pro.
- `researcher.md`: Web search, documentation lookup, codebase exploration.
  Structured output with confidence levels and source citations. Model: deepseek-v4-flash.
- `review.md`: Code review with severity levels (Critical/High/Medium/Low).
  Checks correctness, quality, performance, and repo conventions. Model: kimi-k2.6.
- `git-master.md`: Advanced git operations, conflict resolution, reflog
  recovery. Respects user aliases and extensions
  ([delta](https://github.com/dandavison/delta),
  [difftastic](https://github.com/Wilfred/difftastic),
  [git-absorb](https://github.com/tummychow/git-absorb)).
  Model: mimo-v2.5-pro.

## Commands

Slash commands in `commands/`:

- `make_tests`: Auto-discovers test framework, writes behavioral tests,
  runs them, reports results.
- `learn_from_session`: Extracts evergreen improvements from a session
  to suggest AGENTS.md updates.
- `fullplan`: Re-prints the current task plan.
- `security/ctf`: CTF challenge solver with methodology and fallback strategies.
- `security/audit`: Security audit command.
- `security/pentest`: Penetration testing command.
- `security/review`: Security-focused code review.

## Skills

Skill definitions in `skills/` for the OpenCode skill system:

- `mcp-integration` / `mcp-builder`: MCP server setup and bundling.
- `agent-creator`: Creating new OpenCode agents.
- `skill-development` / `skill-conversion`: Writing and migrating skills.
- `command-development`: Slash command structure and frontmatter.
- `opencode-hooks`: Pre/Post tool-use hooks with conditions and policies.
- `find-skills`: Discovering and installing available skills.
- `pr-summary`: Generate PR descriptions from commit history.

## Scripts

Helper scripts in `scripts/`:

- `lmstudio-models.sh`: Fetches available models from LM Studio API and
  merges them into `opencode.json` (or replaces with `--reset`).
- `deep-merge.js`: Deep-merges JSON files. Used by the model sync scripts.

## Plugins

Dependency: `@opencode-ai/plugin` v1.4.3

- [`opencode-vibeguard`](https://github.com/inkdust2021/opencode-vibeguard):
  External plugin. Redacts sensitive strings before sending to LLM providers.
- `@mohak34/opencode-notifier`: External plugin. Desktop notifications for
  session events (permission requests, completions, errors, questions).
- `plugins/dotenv-protection.ts`: Local plugin. Blocks the read tool and
  bash commands from accessing `.env` files.
- `plugins/rtk.ts`: Local plugin. Intercepts bash commands and rewrites
  them via `rtk rewrite` for token savings (requires rtk >= 0.23.0 in PATH).

## MCP servers

Configured in `opencode.json`:

- Context7: Documentation lookup.
- Grep GitHub: Code search across public repositories.
- exa-search: Web search, crawling, code context, deep research.
- DeepWiki: AI-powered repository documentation queries.
- GitHub (remote, via GitHub Copilot API): Issues, PRs, actions, code
  scanning, secret protection, discussions, projects, users, orgs.

## tools/

`tools/` directory is reserved for future tool definitions. Currently empty.

## .gitignore

Ignores generated/locally-sensitive files: `node_modules/`, `.env*`, `keys/`,
OS files, provider JSON snapshots, offline config variant, and notifier plugin
state.

## Setup

Clone and symlink or copy to `~/.config/opencode/`.
