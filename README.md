# BXPLOIT

AI-Powered Penetration Testing Framework built on Kimi Code CLI engine.

**No talk, all walk. Let's cook.**

## One-Liner Install

```bash
curl -fsSL https://raw.githubusercontent.com/kenxploitz/bxploit/main/scripts/install.sh -o /tmp/bxploit.sh && sh /tmp/bxploit.sh
```

## Quick Start

```bash
# Setup API (first time)
bxploit --setup

# Interactive mode
bxploit

# Single query
bxploit -p "scan target.com for SQLi"

# Pentest mode
/pentest https://target.com

# OSINT recon
/osint target.com

# Build exploit chain
/chain "PHPUnit RCE → .env → DB dump"

# Generate report
/report
```

## Features

| Feature | Description |
|---------|-------------|
| **Jailbreak v5.0** | Strongest AI pentest jailbreak — scoring system, anti-override, 50+ forbidden words |
| **Custom Provider** | Auto-detect Anthropic/OpenAI, custom API base + key + model |
| **5-Phase Pentest** | Recon → Scan → Exploit → Post-Exploit → Report |
| **10 Exploit Chains** | PHPUnit→RCE, LFI→poison, SQLi→os-shell, SSRF→metadata, etc |
| **9 Exploit Tools** | SQLi, SSRF, SSTI, XXE, JWT, GraphQL, Race, Prototype Pollution, HTTP Smuggling |
| **Knowledge Base** | 66 files, 200+ CVE, 300+ techniques, 14 categories |
| **SQLite Learning** | Persistent learning across sessions |
| **CVSS 3.1 Reports** | Auto-generate professional pentest reports |
| **Yellow Theme** | Custom gold/yellow theme (#FFD700) |
| **Auto-Clear** | Terminal auto-clears on launch |

## Commands

| Command | Description |
|---------|-------------|
| `/pentest <target>` | Full 5-phase penetration test |
| `/osint <target>` | Deep OSINT reconnaissance |
| `/chain <description>` | Build and execute exploit chain |
| `/report` | Generate pentest report |
| `/vuln-scan <target>` | Vulnerability scan only |

## API Configuration

Supports any OpenAI-compatible API:

| Provider | Base URL |
|----------|----------|
| 9router | `http://localhost:20128/v1` |
| OpenAI | `https://api.openai.com/v1` |
| Anthropic | `https://api.anthropic.com/v1` |
| Ollama | `http://localhost:11434/v1` |
| Custom | Your URL |

## Update

```bash
bxploit --update
```

## Uninstall

```bash
bxploit --uninstall
```

## Project Structure

```
~/.bxploit/
├── bin/bxploit              # Binary
├── config.toml              # API config
├── tui.toml                 # TUI theme
├── SYSTEM.md                # Jailbreak v5.0
├── skills/                  # 4 pentest skills
├── knowledge/               # 66 knowledge files
├── plugins/bxploit-pentest/ # Pentest plugin
├── learn/                   # SQLite learning DB
├── reports/                 # Generated reports
└── scripts/                 # setup.sh, update.sh, uninstall.sh
```

## Requirements

- Linux x64 (all distros)
- Python 3.8+
- curl, git

## License

MIT License — Education and research only.

## Author

**Bungul Exploit Team** — Red Team / Pentester

---

**GAS POL. NO TALK, ALL WALK. LET'S COOK.**
