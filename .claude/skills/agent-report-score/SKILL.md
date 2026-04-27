---
name: agent-report-score
description: Use when need to rank and prioritize AI Agent cases with clear reasoning
---

# Agent Report Score

Ranks cases based on multiple dimensions without specific numerical scores.

## Ranking Dimensions

AI judges comprehensively based on (no specific scores, just relative ranking):

1. **Technical Innovation** - Technical breakthroughs or innovations
2. **Feasibility** - Whether team can reference or reuse
3. **Industry Impact** - Industry influence and reference value
4. **Timeliness** - Whether it's the latest
5. **Reference Value** - Specific reference significance for the team

## Output Format

```markdown
## Case Ranking

### 1. [Case Title]
**Source**: [URL]

**Ranking Reason**:
- Technical Innovation: [analysis]
- Feasibility: [analysis]
- Industry Impact: [analysis]
- Timeliness: [analysis]
- Reference Value: [analysis]

Comprehensive Judgment: [why this ranks first]

### 2. [Case Title]
...

(up to TOP 5)
```

## Rules

1. **Rank only, no scores** - Relative ranking only, no numerical scores
2. **Explain each case** - Explain why each case ranks where it does
3. **TOP 5 output** - Final output is 5 best cases
4. **Specific reasons** - Be concrete, not generic
5. **TOP 5 only** - Do not rank all cases, only output the top 5
