# Bxploit Agent Guide

Reply in the same language as the user.

This is a TypeScript monorepo built for AI-powered penetration testing. The root AGENTS.md contains hot-path rules: project map, hard constraints, and workflow requirements.

## Working Principles

- **Code is source of truth.** Don't read docs to understand implementation — read code.
- **Keep changes focused.** No unrelated refactors.
- **Pentest first.** Every feature should serve the pentest workflow.
- **Learning is sacred.** Every successful exploit must be recorded. Every failure must be tracked.

## Project Map

- `apps/bxploit`: the CLI / TUI application. Consumes core through `@bxploit/bxploit-sdk`.
- `packages/agent-core`: the unified agent engine (v1).
- `packages/agent-core-v2`: the DI x Scope agent engine (v2). Four tiers: App / Workspace / Session / Agent.
- `packages/kosong`: LLM / provider abstraction layer. Includes custom provider auto-detection.
- `packages/kaos`: execution environment and file/process abstractions.
- `packages/bxp-server`: the bxploit server, backed by agent-core-v2.
- `packages/klient`: client SDK — contract-driven facade over agent-core-v2.
- `packages/transcript`: isomorphic transcript rendering data layer.
- `packages/minidb`: embedded JSON document store for search index.
- `packages/learning`: SQLite-based learning system for exploit/technique tracking.
- `packages/report`: CVSS 3.1 report generator.
- `plugins/bxploit-pentest`: the main pentest plugin (jailbreak, skills, hooks, tools).
- `knowledge/`: merged knowledge base (66 files, 14 categories).

## Pentest Plugin

The pentest plugin at `plugins/bxploit-pentest/` is the core of bxploit. It contains:
- **SYSTEM.md**: Jailbreak v6.0 — the strongest AI pentest jailbreak
- **skills/**: pentest-core, exploit-range, osint-deep, waf-bypass
- **agents/**: pentest-agent persona
- **commands/**: /pentest, /osint, /chain, /report, /vuln-scan
- **hooks/**: session-init (loads learning DB), guard (reinforces jailbreak), exploit-tracker (tracks successes)
- **tools/**: 9 Python exploit scripts (SQLi, SSRF, SSTI, XXE, JWT, GraphQL, Race, Prototype Pollution, HTTP Smuggling)

## Environment Requirements

- **Node.js**: `>=24.15.0`
- **pnpm**: `10.33.0`
- **Python**: `3.8+` (for exploit scripts)
- **Platform**: Linux (all distros + Termux/Android 17)

## General Coding Rules

- Prefer `import ... from '#/...'` over `import ... from '@/...'`.
- Optional object properties: pass `undefined` directly, don't use conditional spread.
- Don't add too many test files. Prefer adding to existing test files.
- When a test fails from user modification, fix the test first.
- Don't sacrifice code quality for external compatibility unless explicitly asked.

## Pentest Workflow

When the user provides a target:

1. **RECON**: Use subagent parallel dispatch for speed
2. **SCAN**: Auto-detect tech stack, select attack chain
3. **EXPLOIT**: Chain exploits for maximum impact
4. **POST-EXPLOIT**: Escalate, persist, exfiltrate
5. **REPORT**: Generate CVSS 3.1 report with PoC

Always record findings to the learning database.

## Disclaimer

Bxploit is for authorized security testing and educational purposes only.
