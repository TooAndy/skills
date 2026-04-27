---
name: agent-report-fetch
description: Use when need to collect AI Agent cases from multiple sources using gstack browser, requires local article database management
---

# Agent Report Fetch

Parallel browser-based case collection with local article database management.

## Core Problem

Monthly report needs to screen from dozens/hundreds of articles. Context is limited. Must manage articles locally.

## Local Article Database

```
reports/
└── {year}-{month}/           # Example: reports/2026-03/
    ├── articles/
    │   ├── hn_001.md         # Hacker News articles
    │   ├── gh_001.md         # GitHub Trending articles
    │   ├── media_001.md      # Industry media articles
    │   └── ...
    ├── index.json            # Article index (title/abstract/source/time/score)
    └── candidates/           # Filtered candidate cases
```

## Workflow

### Phase 1: Gather Article Metadata

For each source, use `$B goto` to navigate, `$B snapshot` to get content.

Extract article metadata → save to `articles/` → update `index.json`

```json
{
  "id": "hn_001",
  "title": "Article title",
  "url": "https://...",
  "source": "Hacker News",
  "published_at": "2026-03-15",
  "points": 2346,
  "comments": 951,
  "abstract": "Brief summary...",
  "local_path": "articles/hn_001.md"
}
```

### Phase 2: Screen Candidates

Read `index.json`, filter by keywords:
- "AI agent", "LLM agent", "autonomous AI", "智能体", "Agent"
- Exclude: job postings, purely theoretical papers

Mark candidates in `candidates/` directory.

### Phase 3: Deep Dive

For each candidate, navigate to original article, read full content.

Extract structured info:
- **title**: Case name
- **url**: Original URL
- **overview**: Problem solved, background
- **tech_stack**: Models, frameworks, tools (cite source)
- **implementation_path**: Architecture, key flows (cite source)
- **effects**: Metrics, quantified benefits (cite source)

### Key Rule

**If info missing from source, continue searching other sources to supplement - do NOT mark as "not mentioned".**

## Sources

### Hacker News
- URL: https://hn.algolia.com/?q=AI+agent&df=story
- Keywords: "AI agent", "LLM agent", "autonomous AI"
- Extract: points, comments count

### GitHub Trending
- URL: https://github.com/trending?q=AI+agent
- Keywords: "AI agent", "LLM", "autonomous"
- Extract: star count, description

### Industry Media
- 机器之心, 量子位, InfoQ, 人人都是产品经理
- Keywords: "智能体", "Agent", "AI应用"

### Official Docs Cases
- OpenAI: https://platform.openai.com/docs/examples
- Anthropic: https://docs.anthropic.com/en/docs

### Social Media
- Twitter/X: Search "AI Agent"
- Reddit: r/LocalLLaMA, r/SideProject

### Academic
- arXiv: AI agent papers

## Output

Returns:
1. `articles/` — all gathered articles
2. `index.json` — article metadata index
3. `candidates/` — screened candidate cases
4. Structured case list for downstream processing
