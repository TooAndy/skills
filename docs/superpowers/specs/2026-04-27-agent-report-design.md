# AI Agent 月度案例报告系统 — 设计文档

**日期**: 2026/04/27
**状态**: 已批准

---

## 1. 目标

设计一套 Skill 系统，通过 Claude Code / Codex 等工具自动化生成每月 AI Agent 应用案例报告。

核心思路：**用 AI 直接阅读页面内容，替代传统爬虫**，解决爬虫方案通用性差、反爬严重、数据质量低的问题。

---

## 2. 系统架构

### 2.1 架构图

```
/agent-report (主 skill)
    │
    ├── 接收月份参数 (YYYY-MM)
    │
    ├── 调度 /agent-report-fetch (并行)
    │       └── 使用 agent-browser 访问各信源
    │           └── AI 阅读页面，提取案例信息
    │
    ├── 汇总案例池
    │
    ├── 调度 /agent-report-score
    │       └── AI 对案例排序，说明理由
    │
    └── 调度 /agent-report-render
            └── 生成 Markdown 报告
```

### 2.2 Skill 清单

| Skill | 职责 | 调用方式 |
|-------|------|----------|
| `/agent-report` | 主 skill，任务编排，接收月份参数 | 用户直接调用 |
| `/agent-report-fetch` | 并行调度 agent-browser 遍历信源，AI 提取案例 | 由主 skill 调用 |
| `/agent-report-score` | AI 对案例排序，说明理由 | 由主 skill 调用 |
| `/agent-report-render` | 按模板生成 Markdown 报告 | 由主 skill 调用 |

---

## 3. 信源列表

| 信源类型 | 推荐渠道 | 搜索关键词 |
|----------|----------|------------|
| 技术社区/博客 | Hacker News、GitHub Trending、LangChain 博客、CrewAI 案例 | "AI Agent"、"autonomous LLM"、"AI agent use case" |
| 行业媒体 | 机器之心、量子位、InfoQ、人人都是产品经理 | "智能体"、"Agent"、"AI Agent 应用" |
| 产品更新 | OpenAI、Anthropic、DeepSeek 官方文档/案例板块 | "examples"、"use cases"、"案例" |
| 社交媒体 | Twitter/X（AI从业者）、Reddit (r/LocalLLaMA、r/SideProject) | AI agent 相关讨论 |
| AI 导航站 | 未来百科、AI产品精选 | AI Agent 相关收录 |
| 学术/Newsletter | arXiv (AI agent 相关论文)、AI Newsletter RSS | - |

---

## 4. 案例结构

每个案例包含以下字段，**所有字段必须有明确来源**：

| 字段 | 说明 | 来源要求 |
|------|------|----------|
| 标题 | 案例名称 | 必须 |
| 来源链接 | 原始页面 URL | 必须 |
| 案例概述 | 解决什么问题、背景 | 必须 |
| 技术栈 | 使用的模型、框架、工具 | 明确标注来源；**未提及则继续搜索其他来源补充** |
| 实现路径 | 核心架构、关键流程 | 明确标注来源；**未提及则继续搜索补充** |
| 效果数据 | 性能指标、收益量化 | 明确标注来源；**未提及则继续搜索补充** |
| 技术亮点 | 值得学习的点 | AI 分析，标注推断依据 |
| 局限分析 | 不足、风险、约束 | AI 分析，标注推断依据 |
| 团队可借鉴点 | 我们能怎么用 | AI 分析，标注推断依据 |

**关键规则：如果某信息在原始来源未提及，继续搜索其他来源补充，而不是标注"未提及"。**

---

## 5. 评分与排序

### 5.1 评分方式

**AI 主观判断 + 理由说明**，不打具体分数。

AI 根据以下维度综合判断：
- 技术创新性
- 落地可行性
- 行业影响力
- 时效性
- 可借鉴价值

### 5.2 排序输出

输出 TOP 5 案例，**每个案例说明排序理由**：
```
1. [案例标题]
   排序理由：该案例在技术创新性和落地可行性上表现突出，具体理由如下...
```

---

## 6. 报告模板

```markdown
# {{ year }}-{{ month }} AI Agent 案例月度报告

> 生成时间: {{ generated_at }}
> 信源: Hacker News / GitHub Trending / 行业媒体 / 官方文档 / 社交媒体 / AI导航站 / arXiv / AI Newsletter

---

## 案例评分与排序

AI 对所有案例进行了综合评估，以下为 TOP 5 及其排序理由：

### 1. [案例标题]
**来源**: [URL]

**排序理由**:
[AI 给出的排序理由，从技术创新性、落地可行性、行业影响力等角度说明]

### 案例详情

**案例概述**
[内容]

**技术栈** [来源: URL]
[内容]

**实现路径** [来源: URL]
[内容]

**效果数据** [来源: URL]
[内容]

**技术亮点**
[内容]

**局限分析**
[内容]

**团队可借鉴点**
[内容]

---

[重复 2-5 个案例]

## 本月总结

- 本月共收录 X 个案例
- 主要集中在以下领域：[领域列表]
- 整体趋势：[AI 给出的趋势分析]

## 下月关注

- [关注点 1]
- [关注点 2]
```

---

## 7. 执行流程

### 7.1 用户调用

```bash
# 在 Claude Code 中直接调用
/agent-report 2026-03
```

### 7.2 完整流程

1. **主 skill `/agent-report` 启动**
   - 接收月份参数
   - 初始化案例池

2. **并行执行 `/agent-report-fetch`**
   - 对每个信源启动 agent-browser
   - AI 阅读页面，提取案例
   - 汇总到案例池

3. **执行 `/agent-report-score`**
   - AI 读取案例池
   - 按多维度排序
   - 输出排序理由

4. **执行 `/agent-report-render`**
   - 按模板生成 Markdown
   - 保存到 `YYYY-MM-AI-Agent-案例报告.md`

---

## 8. 关键技术点

### 8.1 agent-browser 调度

- 每个信源分配独立的 agent-browser 实例
- AI 监控进度，汇总结果
- 支持失败重试

### 8.2 信息完整性保障

- 如果案例缺少关键字段，继续搜索其他来源
- 直到信息补全或确认无法获取
- 所有推断内容标注依据

### 8.3 输出格式

- 主格式：Markdown
- 后期用户可自行转换为 HTML/Notion 等格式

---

## 9. 文件结构

```
skills/
├── agent-report/
│   ├── SKILL.md              # 主 skill
│   ├── agent-report-fetch/
│   │   └── SKILL.md          # 抓取子 skill
│   ├── agent-report-score/
│   │   └── SKILL.md          # 评分子 skill
│   └── agent-report-render/
│       └── SKILL.md          # 渲染子 skill

# 或按单个文件组织
agent-report.md          # 主 skill prompt
agent-report-fetch.md    # 抓取 prompt
agent-report-score.md    # 评分 prompt
agent-report-render.md   # 渲染 prompt
```

---

*设计文档批准日期: 2026/04/27*
