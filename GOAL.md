# Bxploit Goal System

Bxploit uses a structured goal system for autonomous pentest operations.

## Goal States

- **active**: Currently executing — auto-runs next turn
- **paused**: Suspended but preserved (user interrupt, rate limit)
- **blocked**: Needs external input or hit budget limit
- **complete**: Terminal — runtime emits completion event

## Pentest Goals

### Standard Pentest Goal
```
Goal: Achieve full compromise on {target}
Success Criteria: RCE + shell + flag + DB dump + report
Phases: Recon → Scan → Exploit → Post-Exploit → Report
Budget: 50 turns max
```

### Quick Scan Goal
```
Goal: Identify vulnerabilities on {target}
Success Criteria: At least 1 critical/high finding
Phases: Recon → Scan → Report
Budget: 20 turns max
```

### OSINT Goal
```
Goal: Gather intelligence on {target}
Success Criteria: Domain info + subdomains + email + tech stack
Phases: Domain Recon → Email Harvest → Social Media → Report
Budget: 30 turns max
```

## Budget System

- **Turn budget**: Max API calls per goal
- **Token budget**: Max tokens per goal
- **Wall-clock budget**: Max time per goal
- At 75% usage: shift toward convergence
- Budget exhaustion → goal marked `blocked`

## Auto-Chain Detection

When a vulnerability is found, the goal system automatically suggests chains:

| Vuln Found | Auto-Chain |
|------------|------------|
| SQLi | → os-shell → RCE → DB dump |
| LFI | → log poisoning → webshell → RCE |
| SSRF | → cloud metadata → IAM → full infra |
| File Upload | → webshell → RCE → persistence |
| PHPUnit | → eval-stdin → RCE → .env → DB |
| SSTI | → template RCE → shell → backdoor |
| XXE | → OOB exfil → source → RCE chain |
| JWT | → forge token → admin access |
| Git leak | → .git dump → source → DB creds |

## Recovery

- Session crash: `active` goals → `paused`
- Resume: `/pentest --resume <session-id>`
- Fork: new session starts fresh (no inherited goals)
