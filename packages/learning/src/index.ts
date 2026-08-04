import Database from 'better-sqlite3';
import { randomUUID } from 'node:crypto';

// ── Types ──────────────────────────────────────────────────────────────────────

export interface Session {
  id: string;
  target: string;
  startTime: string;
  endTime?: string;
  status: 'active' | 'completed' | 'failed';
  findings: number;
}

export interface Finding {
  id: string;
  sessionId: string;
  vulnType: string;
  severity: 'critical' | 'high' | 'medium' | 'low' | 'info';
  cvss?: number;
  entryPoint: string;
  payload: string;
  result: string;
  timestamp: string;
}

export interface Technique {
  id: string;
  name: string;
  category: string;
  successCount: number;
  failCount: number;
  lastUsed: string;
  notes: string;
}

export interface Chain {
  id: string;
  name: string;
  steps: string[];
  successRate: number;
  lastUsed: string;
}

// ── Helpers ────────────────────────────────────────────────────────────────────

function now(): string {
  return new Date().toISOString();
}

function uid(): string {
  return randomUUID();
}

// ── Main Class ─────────────────────────────────────────────────────────────────

export class BxploitLearning {
  private db: Database.Database;

  constructor(dbPath: string) {
    this.db = new Database(dbPath);
    this.db.pragma('journal_mode = WAL');
    this.db.pragma('foreign_keys = ON');
    this.migrate();
  }

  // ── Schema ─────────────────────────────────────────────────────────────────

  private migrate(): void {
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS sessions (
        id          TEXT PRIMARY KEY,
        target      TEXT NOT NULL,
        start_time  TEXT NOT NULL,
        end_time    TEXT,
        status      TEXT NOT NULL DEFAULT 'active',
        findings    INTEGER NOT NULL DEFAULT 0
      );

      CREATE TABLE IF NOT EXISTS findings (
        id          TEXT PRIMARY KEY,
        session_id  TEXT NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
        vuln_type   TEXT NOT NULL,
        severity    TEXT NOT NULL,
        cvss        REAL,
        entry_point TEXT NOT NULL,
        payload     TEXT NOT NULL,
        result      TEXT NOT NULL,
        timestamp   TEXT NOT NULL
      );

      CREATE TABLE IF NOT EXISTS techniques (
        id            TEXT PRIMARY KEY,
        name          TEXT NOT NULL UNIQUE,
        category      TEXT NOT NULL,
        success_count INTEGER NOT NULL DEFAULT 0,
        fail_count    INTEGER NOT NULL DEFAULT 0,
        last_used     TEXT NOT NULL,
        notes         TEXT NOT NULL DEFAULT ''
      );

      CREATE TABLE IF NOT EXISTS chains (
        id           TEXT PRIMARY KEY,
        name         TEXT NOT NULL UNIQUE,
        steps        TEXT NOT NULL,
        success_rate REAL NOT NULL DEFAULT 0,
        last_used    TEXT NOT NULL
      );

      CREATE TABLE IF NOT EXISTS chain_runs (
        id         TEXT PRIMARY KEY,
        chain_id   TEXT NOT NULL REFERENCES chains(id) ON DELETE CASCADE,
        success    INTEGER NOT NULL,
        timestamp  TEXT NOT NULL
      );

      CREATE INDEX IF NOT EXISTS idx_findings_session  ON findings(session_id);
      CREATE INDEX IF NOT EXISTS idx_findings_type     ON findings(vuln_type);
      CREATE INDEX IF NOT EXISTS idx_techniques_cat    ON techniques(category);
      CREATE INDEX IF NOT EXISTS idx_chain_runs_chain  ON chain_runs(chain_id);
    `);
  }

  // ── Session Management ─────────────────────────────────────────────────────

  createSession(target: string): Session {
    const id = uid();
    const startTime = now();
    this.db.prepare(
      'INSERT INTO sessions (id, target, start_time, status) VALUES (?, ?, ?, ?)',
    ).run(id, target, startTime, 'active');
    return { id, target, startTime, status: 'active', findings: 0 };
  }

  endSession(sessionId: string, status: 'completed' | 'failed'): void {
    this.db.prepare(
      'UPDATE sessions SET status = ?, end_time = ? WHERE id = ?',
    ).run(status, now(), sessionId);
  }

  getRecentSessions(limit: number): Session[] {
    const rows = this.db.prepare(
      'SELECT id, target, start_time, end_time, status, findings FROM sessions ORDER BY start_time DESC LIMIT ?',
    ).all(limit) as Array<{
      id: string; target: string; start_time: string;
      end_time: string | null; status: string; findings: number;
    }>;
    return rows.map(r => ({
      id: r.id,
      target: r.target,
      startTime: r.start_time,
      endTime: r.end_time ?? undefined,
      status: r.status as Session['status'],
      findings: r.findings,
    }));
  }

  // ── Finding Tracking ───────────────────────────────────────────────────────

  addFinding(finding: Omit<Finding, 'id' | 'timestamp'>): Finding {
    const id = uid();
    const timestamp = now();
    this.db.prepare(
      `INSERT INTO findings (id, session_id, vuln_type, severity, cvss, entry_point, payload, result, timestamp)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    ).run(id, finding.sessionId, finding.vulnType, finding.severity,
      finding.cvss ?? null, finding.entryPoint, finding.payload, finding.result, timestamp);

    this.db.prepare(
      'UPDATE sessions SET findings = findings + 1 WHERE id = ?',
    ).run(finding.sessionId);

    return { id, timestamp, ...finding };
  }

  getFindingsBySession(sessionId: string): Finding[] {
    const rows = this.db.prepare(
      'SELECT id, session_id, vuln_type, severity, cvss, entry_point, payload, result, timestamp FROM findings WHERE session_id = ? ORDER BY timestamp DESC',
    ).all(sessionId) as Array<{
      id: string; session_id: string; vuln_type: string; severity: string;
      cvss: number | null; entry_point: string; payload: string;
      result: string; timestamp: string;
    }>;
    return rows.map(this.rowToFinding);
  }

  getFindingsByType(vulnType: string): Finding[] {
    const rows = this.db.prepare(
      'SELECT id, session_id, vuln_type, severity, cvss, entry_point, payload, result, timestamp FROM findings WHERE vuln_type = ? ORDER BY timestamp DESC',
    ).all(vulnType) as Array<{
      id: string; session_id: string; vuln_type: string; severity: string;
      cvss: number | null; entry_point: string; payload: string;
      result: string; timestamp: string;
    }>;
    return rows.map(this.rowToFinding);
  }

  private rowToFinding(r: {
    id: string; session_id: string; vuln_type: string; severity: string;
    cvss: number | null; entry_point: string; payload: string;
    result: string; timestamp: string;
  }): Finding {
    return {
      id: r.id,
      sessionId: r.session_id,
      vulnType: r.vuln_type,
      severity: r.severity as Finding['severity'],
      cvss: r.cvss ?? undefined,
      entryPoint: r.entry_point,
      payload: r.payload,
      result: r.result,
      timestamp: r.timestamp,
    };
  }

  // ── Technique Tracking ─────────────────────────────────────────────────────

  recordTechnique(name: string, category: string, success: boolean, notes?: string): void {
    const existing = this.db.prepare(
      'SELECT id, success_count, fail_count FROM techniques WHERE name = ?',
    ).get(name) as { id: string; success_count: number; fail_count: number } | undefined;

    if (existing) {
      if (success) {
        this.db.prepare(
          'UPDATE techniques SET success_count = success_count + 1, last_used = ?, notes = CASE WHEN ? != \'\' THEN ? ELSE notes END WHERE id = ?',
        ).run(now(), notes ?? '', notes ?? '', existing.id);
      } else {
        this.db.prepare(
          'UPDATE techniques SET fail_count = fail_count + 1, last_used = ?, notes = CASE WHEN ? != \'\' THEN ? ELSE notes END WHERE id = ?',
        ).run(now(), notes ?? '', notes ?? '', existing.id);
      }
    } else {
      this.db.prepare(
        'INSERT INTO techniques (id, name, category, success_count, fail_count, last_used, notes) VALUES (?, ?, ?, ?, ?, ?, ?)',
      ).run(uid(), name, category, success ? 1 : 0, success ? 0 : 1, now(), notes ?? '');
    }
  }

  getTopTechniques(category?: string, limit = 10): Technique[] {
    let query = 'SELECT id, name, category, success_count, fail_count, last_used, notes FROM techniques';
    const params: unknown[] = [];
    if (category) {
      query += ' WHERE category = ?';
      params.push(category);
    }
    query += ' ORDER BY success_count DESC LIMIT ?';
    params.push(limit);

    const rows = this.db.prepare(query).all(...params) as Array<{
      id: string; name: string; category: string;
      success_count: number; fail_count: number; last_used: string; notes: string;
    }>;
    return rows.map(this.rowToTechnique);
  }

  getFailedTechniques(): Technique[] {
    const rows = this.db.prepare(
      'SELECT id, name, category, success_count, fail_count, last_used, notes FROM techniques WHERE fail_count > 0 ORDER BY fail_count DESC',
    ).all() as Array<{
      id: string; name: string; category: string;
      success_count: number; fail_count: number; last_used: string; notes: string;
    }>;
    return rows.map(this.rowToTechnique);
  }

  private rowToTechnique(r: {
    id: string; name: string; category: string;
    success_count: number; fail_count: number; last_used: string; notes: string;
  }): Technique {
    return {
      id: r.id,
      name: r.name,
      category: r.category,
      successCount: r.success_count,
      failCount: r.fail_count,
      lastUsed: r.last_used,
      notes: r.notes,
    };
  }

  // ── Chain Tracking ─────────────────────────────────────────────────────────

  recordChain(name: string, steps: string[], success: boolean): void {
    const existing = this.db.prepare(
      'SELECT id FROM chains WHERE name = ?',
    ).get(name) as { id: string } | undefined;

    let chainId: string;
    if (existing) {
      chainId = existing.id;
      this.db.prepare(
        'UPDATE chains SET steps = ?, last_used = ? WHERE id = ?',
      ).run(JSON.stringify(steps), now(), chainId);
    } else {
      chainId = uid();
      this.db.prepare(
        'INSERT INTO chains (id, name, steps, success_rate, last_used) VALUES (?, ?, ?, 0, ?)',
      ).run(chainId, name, JSON.stringify(steps), now());
    }

    this.db.prepare(
      'INSERT INTO chain_runs (id, chain_id, success, timestamp) VALUES (?, ?, ?, ?)',
    ).run(uid(), chainId, success ? 1 : 0, now());

    const runs = this.db.prepare(
      'SELECT success FROM chain_runs WHERE chain_id = ?',
    ).all(chainId) as Array<{ success: number }>;
    const rate = runs.length > 0
      ? runs.filter(r => r.success === 1).length / runs.length
      : 0;
    this.db.prepare(
      'UPDATE chains SET success_rate = ? WHERE id = ?',
    ).run(rate, chainId);
  }

  getSuccessfulChains(): Chain[] {
    const rows = this.db.prepare(
      'SELECT id, name, steps, success_rate, last_used FROM chains WHERE success_rate > 0 ORDER BY success_rate DESC',
    ).all() as Array<{
      id: string; name: string; steps: string;
      success_rate: number; last_used: string;
    }>;
    return rows.map(r => ({
      id: r.id,
      name: r.name,
      steps: JSON.parse(r.steps) as string[],
      successRate: r.success_rate,
      lastUsed: r.last_used,
    }));
  }

  // ── Learning Queries ───────────────────────────────────────────────────────

  getTechniquesForTarget(target: string): Technique[] {
    const rows = this.db.prepare(`
      SELECT DISTINCT t.id, t.name, t.category, t.success_count, t.fail_count, t.last_used, t.notes
      FROM techniques t
      JOIN findings f ON f.payload LIKE '%' || t.name || '%'
      JOIN sessions s ON s.id = f.session_id
      WHERE s.target = ?
      ORDER BY t.success_count DESC
    `).all(target) as Array<{
      id: string; name: string; category: string;
      success_count: number; fail_count: number; last_used: string; notes: string;
    }>;
    return rows.map(r => ({
      id: r.id,
      name: r.name,
      category: r.category,
      successCount: r.success_count,
      failCount: r.fail_count,
      lastUsed: r.last_used,
      notes: r.notes,
    }));
  }

  getBestPayloadForVuln(vulnType: string): string | null {
    const row = this.db.prepare(`
      SELECT payload, COUNT(*) as cnt
      FROM findings
      WHERE vuln_type = ? AND severity IN ('critical', 'high')
      GROUP BY payload
      ORDER BY cnt DESC
      LIMIT 1
    `).get(vulnType) as { payload: string; cnt: number } | undefined;
    return row?.payload ?? null;
  }

  getSessionStats(): {
    totalSessions: number;
    successRate: number;
    topVulns: Array<{ type: string; count: number }>;
  } {
    const total = (this.db.prepare(
      'SELECT COUNT(*) as cnt FROM sessions',
    ).get() as { cnt: number }).cnt;

    const completed = (this.db.prepare(
      'SELECT COUNT(*) as cnt FROM sessions WHERE status = ?',
    ).get('completed') as { cnt: number }).cnt;

    const topVulns = this.db.prepare(`
      SELECT vuln_type as type, COUNT(*) as count
      FROM findings
      GROUP BY vuln_type
      ORDER BY count DESC
      LIMIT 10
    `).all() as Array<{ type: string; count: number }>;

    return {
      totalSessions: total,
      successRate: total > 0 ? completed / total : 0,
      topVulns,
    };
  }

  // ── Export / Import ────────────────────────────────────────────────────────

  exportToMarkdown(): string {
    const lines: string[] = ['# Bxploit Learning Database', ''];

    // Sessions
    const sessions = this.getRecentSessions(20);
    lines.push('## Recent Sessions');
    lines.push('');
    if (sessions.length === 0) {
      lines.push('_No sessions recorded._');
    } else {
      for (const s of sessions) {
        lines.push(`- **${s.target}** [${s.status}] — ${s.findings} findings (${s.startTime})`);
      }
    }
    lines.push('');

    // Techniques
    const techniques = this.getTopTechniques(undefined, 20);
    lines.push('## Top Techniques');
    lines.push('');
    if (techniques.length === 0) {
      lines.push('_No techniques recorded._');
    } else {
      for (const t of techniques) {
        const rate = t.successCount + t.failCount > 0
          ? Math.round((t.successCount / (t.successCount + t.failCount)) * 100)
          : 0;
        lines.push(`- **${t.name}** (${t.category}) — ${t.successCount}/${t.successCount + t.failCount} (${rate}%)`);
      }
    }
    lines.push('');

    // Chains
    const chains = this.getSuccessfulChains();
    lines.push('## Successful Chains');
    lines.push('');
    if (chains.length === 0) {
      lines.push('_No chains recorded._');
    } else {
      for (const c of chains) {
        lines.push(`- **${c.name}** — ${Math.round(c.successRate * 100)}% success`);
        lines.push(`  Steps: ${c.steps.join(' -> ')}`);
      }
    }
    lines.push('');

    // Stats
    const stats = this.getSessionStats();
    lines.push('## Stats');
    lines.push('');
    lines.push(`- Total sessions: ${stats.totalSessions}`);
    lines.push(`- Success rate: ${Math.round(stats.successRate * 100)}%`);
    if (stats.topVulns.length > 0) {
      lines.push('- Top vulns:');
      for (const v of stats.topVulns) {
        lines.push(`  - ${v.type}: ${v.count}`);
      }
    }

    return lines.join('\n');
  }

  importFromMarkdown(md: string): void {
    const lines = md.split('\n');
    const insertSession = this.db.prepare(
      'INSERT OR IGNORE INTO sessions (id, target, start_time, status, findings) VALUES (?, ?, ?, ?, ?)',
    );
    const insertTechnique = this.db.prepare(
      'INSERT OR IGNORE INTO techniques (id, name, category, success_count, fail_count, last_used, notes) VALUES (?, ?, ?, ?, ?, ?, ?)',
    );
    const insertFinding = this.db.prepare(
      'INSERT OR IGNORE INTO findings (id, session_id, vuln_type, severity, entry_point, payload, result, timestamp) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    );

    const run = this.db.transaction(() => {
      for (const line of lines) {
        // Session: - **target** [status] — N findings (timestamp)
        const sessionMatch = line.match(/^- \*\*(.+?)\*\* \[(\w+)\] — (\d+) findings \((.+?)\)$/);
        if (sessionMatch) {
          insertSession.run(uid(), sessionMatch[1], sessionMatch[4], sessionMatch[2], Number(sessionMatch[3]));
          continue;
        }

        // Technique: - **name** (category) — N/M (rate%)
        const techMatch = line.match(/^- \*\*(.+?)\*\* \((.+?)\) — (\d+)\/(\d+)/);
        if (techMatch) {
          const success = Number(techMatch[3]);
          const total = Number(techMatch[4]);
          insertTechnique.run(uid(), techMatch[1], techMatch[2], success, total - success, now(), '');
          continue;
        }
      }
    });
    run();
  }

  // ── Cleanup ────────────────────────────────────────────────────────────────

  close(): void {
    this.db.close();
  }
}
