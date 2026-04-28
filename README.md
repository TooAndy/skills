# Skills

AI Agent 技能仓库，包含以下技能模块：

## 技能列表

### wechat-article-scraper

微信公众号文章爬取技能。从微信专辑页面抓取文章并保存为 Markdown 格式。

详细说明：[skills/wechat-article-scraper/SKILL.md](skills/wechat-article-scraper/SKILL.md)

### monthly_agent_info_report

AI Agent 案例月度报告生成技能。从多个信源（Hacker News、GitHub Trending、产品官网、行业媒体、技术博客）收集信息，生成月度 AI Agent 案例报告。

详细说明：[skills/monthly_agent_info_report/agent-report/SKILL.md](skills/monthly_agent_info_report/agent-report/SKILL.md)

## 报告输出

生成的报告存放在 `reports/` 目录下，按月份组织：

```
reports/
└── 2026-04/
    ├── 2026-04-AI-Agent-案例报告.md  # 月度主报告
    ├── deep_dive/                    # 深度分析候选案例
    └── wechat_articles/              # 爬取的微信文章原文
```

## 目录结构

```
skills/
├── wechat-article-scraper/          # 微信文章爬虫技能
└── monthly_agent_info_report/       # 月度报告生成技能
    ├── agent-report/                # 主报告生成器
    ├── agent-report-screen/         # 候选案例初筛
    ├── agent-report-broad-search/   # 广泛搜索
    ├── agent-report-deep-dive/      # 深度分析
    ├── agent-report-score/          # 案例评分
    └── agent-report-render/         # 报告渲染
```