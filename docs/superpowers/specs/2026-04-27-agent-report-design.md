# AI Agent 月度案例报告系统 — 设计文档

**日期**: 2026/04/27
**状态**: 已批准 (v2)

---

## 1. 目标

设计一套 Skill 系统，通过 Claude Code / Codex + gstack browse 自动化生成每月 AI Agent 应用案例报告。

核心思路：
- **gstack browse 替代爬虫** — AI 直接阅读页面，不依赖 CSS 选择器
- **本地文章库** — 解决上下文长度问题，支持海量筛选
- **分阶段工作流** — 抓取 → 筛选 → 精选 → 报告

---

## 2. 系统架构

### 2.1 架构图

```
用户调用 /agent-report 2026-03
    │
    ├── Step 1: 创建月度目录
    │       reports/2026-03/
    │
    ├── Step 2: agent-report-fetch (并行)
    │       ├── gstack browse 访问各信源
    │       ├── 提取文章元信息
    │       ├── 存入 articles/
    │       ├── 构建 index.json
    │       └── 筛选候选 → candidates/
    │
    ├── Step 3: agent-report-score
    │       ├── 读取 index.json
    │       ├── 按多维度排序
    │       └── 输出 TOP 5 + 理由
    │
    ├── Step 4: 深度分析 (per candidate)
    │       └── 访问原文，提取详细信息
    │
    ├── Step 5: agent-report-render
    │       └── 生成 Markdown 报告
    │
    └── 输出: YYYY-MM-AI-Agent-案例报告.md
```

### 2.2 本地文章库结构

```
reports/
└── {year}-{month}/              # 例: reports/2026-03/
    ├── articles/                 # 所有抓取的文章
    │   ├── hn_001.md           # Hacker News
    │   ├── hn_002.md
    │   ├── gh_001.md           # GitHub
    │   ├── media_001.md       # 行业媒体
    │   └── ...
    ├── index.json               # 文章索引
    ├── candidates/              # 候选案例
    └── YYYY-MM-AI-Agent-案例报告.md  # 最终报告
```

### 2.3 index.json 格式

```json
{
  "month": "2026-03",
  "created_at": "2026-04-27",
  "articles": [
    {
      "id": "hn_001",
      "title": "An AI agent deleted our production database",
      "url": "https://twitter.com/...",
      "source": "Hacker News",
      "published_at": "2026-03-15",
      "points": 685,
      "comments": 830,
      "abstract": "A practitioner's confession...",
      "local_path": "articles/hn_001.md",
      "tags": ["ai-agent", "incident", "production"]
    }
  ],
  "total_count": 47
}
```

---

## 3. 信源列表

| 信源类型 | 推荐渠道 | 搜索关键词 |
|----------|----------|------------|
| 技术社区 | Hacker News (hn.algolia.com) | "AI agent", "LLM agent" |
| 技术社区 | GitHub Trending | "AI agent", "LLM", "autonomous" |
| 行业媒体 | 机器之心、量子位、InfoQ、人人都是产品经理 | "智能体", "Agent" |
| 官方文档 | OpenAI、Anthropic、DeepSeek 案例板块 | "examples", "use cases" |
| 社交媒体 | Twitter/X、Reddit (r/LocalLLaMA) | "AI Agent" |
| 学术 | arXiv | "AI agent", "LLM agent" |

---

## 4. Skill 清单

| Skill | 职责 |
|-------|------|
| `/agent-report` | 主 skill，任务编排 |
| `/agent-report-fetch` | 并行抓取，gstack browse + 本地文章库 |
| `/agent-report-score` | 多维度排序，输出 TOP 5 |
| `/agent-report-render` | 生成 Markdown 报告 |

---

## 5. 案例结构

每个案例包含（所有信息必须有明确来源）：

| 字段 | 说明 | 来源要求 |
|------|------|----------|
| 标题 | 案例名称 | 必须 |
| 来源链接 | 原始页面 URL | 必须 |
| 案例概述 | 解决什么问题、背景 | 必须 |
| 技术栈 | 模型、框架、工具 | 明确标注来源；**缺失则继续搜索补充** |
| 实现路径 | 核心架构、关键流程 | 明确标注来源 |
| 效果数据 | 性能指标、收益量化 | 明确标注来源 |
| 技术亮点 | 值得学习的点 | AI 分析，标注依据 |
| 局限分析 | 不足、风险、约束 | AI 分析，标注依据 |
| 团队可借鉴点 | 我们能怎么用 | AI 分析，标注依据 |

---

## 6. 评分机制

**AI 主观判断 + 理由说明**，不打具体分数。

评分维度：
1. **技术创新性** — 是否有技术突破
2. **落地可行性** — 团队是否可以借鉴
3. **行业影响力** — 对行业的影响
4. **时效性** — 是否当月最新
5. **可借鉴价值** — 对团队的具体意义

输出格式：
```markdown
### 1. [案例标题]
**排序理由**:
- 技术创新性：[分析]
- 落地可行性：[分析]
- 行业影响力：[分析]
- 时效性：[分析]
- 可借鉴价值：[分析]
综合判断：[总结]
```

---

## 7. 报告模板

```markdown
# {{ year }}-{{ month }} AI Agent 案例月度报告

> 生成时间: {{ generated_at }}
> 信源: Hacker News / GitHub Trending / 行业媒体 / 官方文档 / 社交媒体 / arXiv

---

## 案例评分与排序

TOP 5 案例及其排序理由：

### {{ index }}. {{ title }}
**来源**: {{ url }}

**排序理由**:
{{ ranking_reason }}

### 案例详情

**案例概述**
{{ overview }}

**技术栈** {{ source }}
{{ tech_stack }}

**实现路径** {{ source }}
{{ implementation_path }}

**效果数据** {{ source }}
{{ effects }}

**技术亮点**
{{ highlights }}

**局限分析**
{{ limitations }}

**团队可借鉴点**
{{ takeaways }}

---

## 本月总结

## 下月关注
```

---

*设计文档批准日期: 2026/04/27 (v2)*
