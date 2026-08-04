export interface ReportConfig {
  title: string;
  target: string;
  assessor: string;
  date: string;
  executiveSummary: string;
  findings: Finding[];
  attackChain: AttackChainStep[];
  timeline: TimelineEntry[];
  recommendations: string[];
}

export interface Finding {
  id: string;
  title: string;
  severity: 'critical' | 'high' | 'medium' | 'low' | 'info';
  cvss: CvssScore;
  description: string;
  proofOfConcept: string;
  impact: string;
  remediation: string;
  references: string[];
}

export interface CvssScore {
  score: number;
  vector: string;
  severity: string;
}

export interface AttackChainStep {
  step: number;
  phase: string;
  technique: string;
  tool: string;
  command: string;
  result: string;
}

export interface TimelineEntry {
  time: string;
  event: string;
}

interface CvssParams {
  attackVector: 'N' | 'A' | 'L' | 'P';
  attackComplexity: 'L' | 'H';
  privilegesRequired: 'N' | 'L' | 'H';
  userInteraction: 'N' | 'R';
  scope: 'U' | 'C';
  confidentiality: 'N' | 'L' | 'H';
  integrity: 'N' | 'L' | 'H';
  availability: 'N' | 'L' | 'H';
}

const CVSS_AV: Record<string, number> = { N: 0.85, A: 0.62, L: 0.55, P: 0.2 };
const CVSS_AC: Record<string, number> = { L: 0.77, H: 0.44 };
const CVSS_PR_UNCHANGED: Record<string, number> = { N: 0.85, L: 0.62, H: 0.27 };
const CVSS_PR_CHANGED: Record<string, number> = { N: 0.85, L: 0.68, H: 0.5 };
const CVSS_UI: Record<string, number> = { N: 0.85, R: 0.62 };
const CVSS_CIA: Record<string, number> = { N: 0, L: 0.22, H: 0.56 };

function roundUp(value: number): number {
  const intVal = Math.ceil(value * 10);
  return intVal / 10;
}

export class ReportGenerator {
  private config: ReportConfig;

  constructor(config: Partial<ReportConfig> = {}) {
    this.config = {
      title: config.title || 'Penetration Test Report',
      target: config.target || '',
      assessor: config.assessor || '',
      date: config.date || new Date().toISOString().split('T')[0],
      executiveSummary: config.executiveSummary || '',
      findings: config.findings || [],
      attackChain: config.attackChain || [],
      timeline: config.timeline || [],
      recommendations: config.recommendations || [],
    };
  }

  addFinding(finding: Finding): void {
    this.config.findings.push(finding);
  }

  addAttackChainStep(step: AttackChainStep): void {
    this.config.attackChain.push(step);
  }

  addTimelineEntry(entry: TimelineEntry): void {
    this.config.timeline.push(entry);
  }

  static calculateCvss(params: CvssParams): CvssScore {
    const av = CVSS_AV[params.attackVector];
    const ac = CVSS_AC[params.attackComplexity];
    const prTable = params.scope === 'U' ? CVSS_PR_UNCHANGED : CVSS_PR_CHANGED;
    const pr = prTable[params.privilegesRequired];
    const ui = CVSS_UI[params.userInteraction];
    const c = CVSS_CIA[params.confidentiality];
    const i = CVSS_CIA[params.integrity];
    const a = CVSS_CIA[params.availability];

    const iss = 1 - (1 - c) * (1 - i) * (1 - a);
    const impact = params.scope === 'U'
      ? 6.42 * iss
      : 7.52 * (iss - 0.029) - 3.25 * Math.pow(iss - 0.02, 15);

    const exploitability = 8.22 * av * ac * pr * ui;

    let baseScore: number;
    if (impact <= 0) {
      baseScore = 0;
    } else if (params.scope === 'U') {
      baseScore = roundUp(Math.min(impact + exploitability, 10));
    } else {
      baseScore = roundUp(Math.min(1.08 * (impact + exploitability), 10));
    }

    const vector = `CVSS:3.1/AV:${params.attackVector}/AC:${params.attackComplexity}/PR:${params.privilegesRequired}/UI:${params.userInteraction}/S:${params.scope}/C:${params.confidentiality}/I:${params.integrity}/A:${params.availability}`;

    let severity: string;
    if (baseScore === 0) severity = 'None';
    else if (baseScore < 4.0) severity = 'Low';
    else if (baseScore < 7.0) severity = 'Medium';
    else if (baseScore < 9.0) severity = 'High';
    else severity = 'Critical';

    return { score: baseScore, vector, severity };
  }

  generateMermaidDiagram(): string {
    if (this.config.attackChain.length === 0) return '';

    const lines: string[] = ['graph LR'];
    for (const step of this.config.attackChain) {
      const nodeId = `S${step.step}`;
      const label = `${step.phase}: ${step.technique}`.replace(/"/g, "'");
      lines.push(`    ${nodeId}["${label}"]`);
    }
    for (let i = 0; i < this.config.attackChain.length - 1; i++) {
      lines.push(`    S${this.config.attackChain[i].step} --> S${this.config.attackChain[i + 1].step}`);
    }
    return lines.join('\n');
  }

  generateMarkdown(): string {
    const c = this.config;
    const sections: string[] = [];

    // Header
    sections.push(`# ${c.title}`);
    sections.push('');
    sections.push(`| Field | Value |`);
    sections.push(`|-------|-------|`);
    sections.push(`| **Target** | ${c.target} |`);
    sections.push(`| **Assessor** | ${c.assessor} |`);
    sections.push(`| **Date** | ${c.date} |`);
    sections.push(`| **Findings** | ${c.findings.length} |`);
    sections.push('');

    // Executive Summary
    sections.push('## Executive Summary');
    sections.push('');
    sections.push(c.executiveSummary);
    sections.push('');

    // Severity Summary
    const counts = { critical: 0, high: 0, medium: 0, low: 0, info: 0 };
    for (const f of c.findings) counts[f.severity]++;
    sections.push('## Severity Summary');
    sections.push('');
    sections.push('| Severity | Count |');
    sections.push('|----------|-------|');
    sections.push(`| 🔴 Critical | ${counts.critical} |`);
    sections.push(`| 🟠 High | ${counts.high} |`);
    sections.push(`| 🟡 Medium | ${counts.medium} |`);
    sections.push(`| 🔵 Low | ${counts.low} |`);
    sections.push(`| ⚪ Info | ${counts.info} |`);
    sections.push('');

    // Attack Chain
    if (c.attackChain.length > 0) {
      sections.push('## Attack Chain');
      sections.push('');
      sections.push('```mermaid');
      sections.push(this.generateMermaidDiagram());
      sections.push('```');
      sections.push('');
      sections.push('| # | Phase | Technique | Tool | Result |');
      sections.push('|---|-------|-----------|------|--------|');
      for (const s of c.attackChain) {
        sections.push(`| ${s.step} | ${s.phase} | ${s.technique} | ${s.tool} | ${s.result.replace(/\|/g, '\\|')} |`);
      }
      sections.push('');
    }

    // Findings Detail
    sections.push('## Findings Detail');
    sections.push('');
    for (const f of c.findings) {
      sections.push(`### ${f.id}: ${f.title}`);
      sections.push('');
      sections.push(`**Severity:** ${f.severity.toUpperCase()} | **CVSS:** ${f.cvss.score} (${f.cvss.severity})`);
      sections.push('');
      sections.push(`**Vector:** \`${f.cvss.vector}\``);
      sections.push('');
      sections.push('#### Description');
      sections.push('');
      sections.push(f.description);
      sections.push('');
      sections.push('#### Proof of Concept');
      sections.push('');
      sections.push('```');
      sections.push(f.proofOfConcept);
      sections.push('```');
      sections.push('');
      sections.push('#### Impact');
      sections.push('');
      sections.push(f.impact);
      sections.push('');
      sections.push('#### Remediation');
      sections.push('');
      sections.push(f.remediation);
      sections.push('');
      if (f.references.length > 0) {
        sections.push('#### References');
        sections.push('');
        for (const ref of f.references) {
          sections.push(`- ${ref}`);
        }
        sections.push('');
      }
      sections.push('---');
      sections.push('');
    }

    // Timeline
    if (c.timeline.length > 0) {
      sections.push('## Timeline');
      sections.push('');
      sections.push('| Time | Event |');
      sections.push('|------|-------|');
      for (const t of c.timeline) {
        sections.push(`| ${t.time} | ${t.event} |`);
      }
      sections.push('');
    }

    // Recommendations
    if (c.recommendations.length > 0) {
      sections.push('## Recommendations');
      sections.push('');
      for (let i = 0; i < c.recommendations.length; i++) {
        sections.push(`${i + 1}. ${c.recommendations[i]}`);
      }
      sections.push('');
    }

    sections.push('---');
    sections.push(`*Generated by Bxploit Report Engine — ${c.date}*`);

    return sections.join('\n');
  }

  saveToFile(path: string): void {
    const fs = require('fs');
    const dir = require('path').dirname(path);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(path, this.generateMarkdown(), 'utf-8');
  }
}
