---
name: agent-report-render
description: Use when need to generate AI Agent case report in Markdown format
---

# Agent Report Render

Generates Markdown report from ranked cases.

## Input

```json
{
  "year": 2026,
  "month": 3,
  "generated_at": "2026-04-27 15:00:00",
  "cases": [
    {
      "title": "Case Title",
      "url": "https://...",
      "ranking_reason": "Ranking reason text",
      "overview": "Case overview",
      "tech_stack": "Tech stack details",
      "implementation_path": "Implementation path",
      "effects": "Effect data",
      "highlights": "Technical highlights",
      "limitations": "Limitations analysis",
      "takeaways": "Team takeaways"
    }
  ]
}
```

## Report Template

```markdown
# {{ year }}-{{ month }} AI Agent 案例月度报告

> 生成时间: {{ generated_at }}
> 信源: Hacker News / GitHub Trending / 行业媒体 / 官方文档 / 社交媒体 / AI导航站 / arXiv / AI Newsletter

---

## 案例评分与排序

AI 对所有案例进行了综合评估，以下为 TOP 5 及其排序理由：

### {{ index }}. {{ title }}
**来源**: {{ url }}

**排序理由**:
{{ ranking_reason }}

### 案例详情

**案例概述**
{{ overview }}

**技术栈**
{{ tech_stack }}

**实现路径**
{{ implementation_path }}

**效果数据**
{{ effects }}

**技术亮点**
{{ highlights }}

**局限分析**
{{ limitations }}

**团队可借鉴点**
{{ takeaways }}

---

## 本月总结

- 本月共收录 {{ cases|length }} 个案例
- 主要集中在以下领域：
- 整体趋势：

## 下月关注

-
```

## Output

Saves to `YYYY-MM-AI-Agent-案例报告.md` in current working directory.
