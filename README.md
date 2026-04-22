# opencode-config

Personal [OpenCode](https://github.com/anomalyco/opencode) configuration for
open-weight and locally-hosted models. Not a framework — just config files that
evolved from daily use.

## What this is

This repo contains my OpenCode setup. The focus is routing to local inference
engines and open-weight models rather than proprietary APIs.

Models run through:
- [LM Studio](https://lmstudio.ai/)
- [Ollama](https://ollama.com/)
- [LlamaBarn](https://github.com/ggml-org/LlamaBarn)
- OpenRouter

### Notes

This configuration uses restrained permissions by default. Agents have restricted
tool access — the orchestrator cannot edit files directly, bash commands require
explicit approval, and destructive operations are gated. The intent is to force
proper delegation to specialized agents and reduce accidental damage. You may find
this conservative approach works better than fully permissive defaults.

## Files

- `opencode.json` — Main config. Provider definitions, agent model routing,
  permissions, MCP server setup, and plugin list.
- `AGENTS.md` — Global rules that all agents inherit. Task management,
  code style, git conventions, terminal behavior.
- `prompts/` — Shared prompt templates. Not consumed by OpenCode directly,
  but referenced by some skills and commands.

## Agents

Custom agents live in `agents/` with YAML frontmatter. Each has a specific
role and restricted permissions:

- `orchestrator.md` — Coordinates multi-phase tasks. Routes work to other
  agents. Cannot edit files or run commands directly.
- `researcher.md` — Web search, documentation lookup, codebase exploration.
  Structured output with confidence levels and source citations.
- `review.md` — Code review with severity levels (Critical/High/Medium/Low).
  Checks correctness, quality, performance, and repo conventions.
- `git-master.md` — Advanced git operations, conflict resolution, reflog
  recovery. Respects user aliases and extensions
  ([delta](https://github.com/dandavison/delta),
  [difftastic](https://github.com/Wilfred/difftastic),
  [git-absorb](https://github.com/tummychow/git-absorb)).

## Commands

Slash commands in `commands/`:

- `make_tests` — Auto-discovers test framework, writes behavioral tests,
  runs them, reports results.
- `learn_from_session` — Extracts evergreen improvements from a session
  to suggest AGENTS.md updates.
- `fullplan` — Re-prints the current task plan.
- `security/ctf` — CTF challenge solver with methodology and fallback strategies.
- `security/audit` — Security audit command.
- `security/pentest` — Penetration testing command.
- `security/review` — Security-focused code review.

## Skills

Skill definitions in `skills/` for the OpenCode skill system:

- `mcp-integration` / `mcp-builder` — MCP server setup and bundling.
- `agent-creator` — Creating new OpenCode agents.
- `skill-development` / `skill-conversion` — Writing and migrating skills.
- `command-development` — Slash command structure and frontmatter.
- `opencode-hooks` — Pre/Post tool-use hooks with conditions and policies.
- `find-skills` — Discovering and installing available skills.

## Scripts

Helper scripts in `scripts/`:

- `lmstudio-models.sh` — Fetches available models from LM Studio API and
  merges them into `opencode.json` (or replaces with `--reset`).
- `llamabarn-models.sh` — Same for LlamaBarn API, including context-size
  extraction from server args.
- `deep-merge.js` — Deep-merges JSON files. Used by the model sync scripts.

## Plugins

- [`opencode-vibeguard`](https://github.com/inkdust2021/opencode-vibeguard) —
  External plugin referenced in `opencode.json`. Redacts sensitive strings
  before sending to LLM providers.
- `plugins/dotenv-protection.js` — Local plugin. Blocks the read tool from
  accessing `.env` files.

## MCP servers

Configured in `opencode.json`:

- Context7 — Documentation lookup.
- Grep GitHub — Code search across public repositories.
- exa-search — Web search, crawling, code context, deep research.

## Setup

Clone and symlink or copy to `~/.config/opencode/`.


