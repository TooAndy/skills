---
name: agent-report
description: Use when generating monthly AI Agent case reports, requires orchestrating multiple sub-skills for fetch, score, and render phases
---

# Agent Report

Monthly AI Agent case report generation system using gstack browser with local article database.

## Prerequisites

Ensure gstack browse is connected before running:
```bash
$HOME/.claude/skills/gstack/browse/dist/browse connect
```

## Local Article Database

Articles are stored locally for context management:

```
reports/
└── {year}-{month}/           # Example: reports/2026-03/
    ├── articles/              # All gathered articles
    ├── index.json             # Article metadata index
    ├── candidates/            # Screened candidate cases
    └── YYYY-MM-AI-Agent-案例报告.md  # Final report
```

## Workflow

### Step 1: Setup Directory
Create `reports/{year}-{month}/` structure.

### Step 2: Fetch via agent-report-fetch
1. Gather article metadata from all sources using gstack browse
2. Save articles to `articles/`
3. Build `index.json`
4. Screen candidates → `candidates/`

### Step 3: Rank via agent-report-score
1. Read index.json
2. Score candidates by: Technical Innovation, Feasibility, Industry Impact, Timeliness, Reference Value
2. Output TOP 5 ranking with reasoning

### Step 4: Deep Dive (per candidate)
For each TOP 5, navigate to original article, extract full details.

### Step 5: Render via agent-report-render
Generate Markdown report.

### Step 6: Output
Save to `YYYY-MM-AI-Agent-案例报告.md`

## Sources

- Hacker News (hn.algolia.com)
- GitHub Trending (github.com/trending?q=AI+agent)
- 机器之心, 量子位, InfoQ, 人人都是产品经理
- OpenAI, Anthropic, DeepSeek docs
- Twitter/X, Reddit
- arXiv

## Usage

```
/agent-report 2026-03
```
