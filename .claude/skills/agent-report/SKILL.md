---
name: agent-report
description: Use when generating monthly AI Agent case reports, requires orchestrating multiple sub-skills for fetch, score, and render phases
---

# Agent Report

月度 AI Agent 案例报告生成系统。

## 工作流（5 阶段）

```
阶段 1: /agent-report-broad-search
    └── 广度搜索: 从多个信源收集 100-500 条候选 → index.json
    └── 中文信源: 微信公众号文章必须保存到 wechat_articles/ 目录

阶段 2: /agent-report-screen
    └── 初筛: 从候选中选出 TOP 10 → candidates/

阶段 3: /agent-report-deep-dive
    └── 深度剖析: 对 TOP 10 进行 5-layer 分析 → deep_dive/

阶段 4: /agent-report-score
    └── 评分排序: 从 TOP 10 选出 TOP 5 → ranking.json

阶段 5: /agent-report-render
    └── 渲染: 生成最终报告 → YYYY-MM-AI-Agent-案例报告.md
```

## 本地数据库结构

```
reports/
└── {year}-{month}/              # Example: reports/2026-04/
    ├── index.json                  # 阶段1: 100-500 条候选
    ├── raw_articles/               # 阶段1: 英文/HN 文章缓存（可选）
    ├── wechat_articles/           # 阶段1: 微信公众号文章缓存（必须）
    │   ├── 机器之心_AI产业动态/
    │   ├── 机器之心_AI开源项目/
    │   └── ...
    ├── candidates/                 # 阶段2: TOP 10 候选
    │   ├── candidate_001.json
    │   └── ...
    ├── deep_dive/                 # 阶段3: TOP 10 深度剖析
    │   ├── candidate_001.md
    │   └── ...
    ├── ranking.json               # 阶段4: TOP 5 排序
    └── 2026-04-AI-Agent-案例报告.md  # 阶段5: 最终报告
```

## 案例分析框架（5-Layer）

每个案例按以下结构分析：

1. **业务与场景定义** - 解决什么问题、场景边界、ROI
2. **技术架构与能力** - Agent 角色、基座模型、工具集、记忆机制
3. **数据流与工作流** - 触发机制、决策逻辑、状态管理
4. **工程落地与运维** - 部署方式、性能指标、监控、容错
5. **风险与合规** - 幻觉控制、数据安全、工具安全

## 案例类型

**聚焦**: 实际落地的 AI Agent 应用（OpenCode、Manus、CrewAI 等）

**非独立案例**: 事故类（删库、发黑料）作为局限性引用，不作为独立案例

## 重复案例排除

阶段2（初筛）会自动检查历史报告，避免重复选入相同案例：
- 如果案例在历史报告中已详细剖析过，**默认排除**
- 如果案例有**重大更新**，可入选但聚焦于更新点
- 详情见 `/agent-report-screen` 的"重复案例排除"章节

## 使用方式

```bash
# 完整执行
/agent-report 2026-04

# 分阶段执行
/agent-report-broad-search 2026-04  # 阶段1: 广度搜索
/agent-report-screen 2026-04         # 阶段2: 初筛
/agent-report-deep-dive 2026-04     # 阶段3: 深度剖析
/agent-report-score 2026-04          # 阶段4: 评分排序
/agent-report-render 2026-04         # 阶段5: 渲染报告
```

## Sub Skills

| Skill | 职责 |
|-------|------|
| `/agent-report-broad-search` | 阶段1: 广度搜索多信源 |
| `/agent-report-screen` | 阶段2: 初筛 TOP 10 |
| `/agent-report-deep-dive` | 阶段3: 深度剖析 TOP 10 |
| `/agent-report-score` | 阶段4: 评分排序 TOP 5 |
| `/agent-report-render` | 阶段5: 渲染最终报告 |
