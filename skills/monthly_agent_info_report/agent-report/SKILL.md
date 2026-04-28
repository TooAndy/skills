---
name: agent-report
description: Use when generating monthly AI Agent case reports, requires orchestrating multiple sub-skills for fetch, score, and render phases
---

# Agent Report

月度 AI Agent 案例报告生成系统。

## 工作流（5 阶段，使用子 Agent 隔离上下文）

每个阶段在独立的子 Agent 中执行，避免上下文污染。

```
阶段 1: /agent-report-broad-search
    └── 使用子 agent 执行广度搜索
    └── 输出: index.json (100-500 条候选)
    └── 中文信源: 微信公众号文章必须保存到 wechat_articles/ 目录

阶段 2: /agent-report-screen
    └── 使用子 agent 执行初筛
    └── 输出: candidates/ (TOP 10)

阶段 3: /agent-report-deep-dive
    └── 使用子 agent 执行深度剖析
    └── 输出: deep_dive/ (TOP 10 5-layer 分析)

阶段 4: /agent-report-score
    └── 使用子 agent 执行评分排序
    └── 输出: ranking.json (TOP 5)

阶段 5: /agent-report-render
    └── 使用子 agent 执行渲染
    └── 输出: YYYY-MM-AI-Agent-案例报告.md
```

### 子 Agent 执行机制

使用 `Agent` 工具启动独立子 Agent，每个阶段：
1. 等待子 Agent 完成
2. 主 Agent 读取阶段输出
3. 启动下一阶段子 Agent

### 断点续跑

如果执行中断，可重新执行 `/agent-report <year-month>`，已完成的阶段会自动跳过。

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
# 完整执行（自动使用子 agent）
/agent-report 2026-04

# 分阶段执行（手动模式，可单独调试）
/agent-report-broad-search 2026-04  # 阶段1: 广度搜索
/agent-report-screen 2026-04         # 阶段2: 初筛
/agent-report-deep-dive 2026-04     # 阶段3: 深度剖析
/agent-report-score 2026-04          # 阶段4: 评分排序
/agent-report-render 2026-04         # 阶段5: 渲染报告
```

## 完整执行流程（子 Agent 模式）

当执行 `/agent-report <year-month>` 时，编排器按以下顺序执行：

```
1. 检查 reports/{year-month}/index.json 是否存在
2. 不存在 → 启动子 agent 执行 agent-report-broad-search
3. 检查 reports/{year-month}/candidates/ 是否有 10 个候选
4. 不足 10 个 → 启动子 agent 执行 agent-report-screen
5. 检查 reports/{year-month}/deep_dive/ 是否有 10 个分析
6. 不足 10 个 → 启动子 agent 执行 agent-report-deep-dive
7. 检查 reports/{year-month}/ranking.json 是否存在
8. 不存在 → 启动子 agent 执行 agent-report-score
9. 检查 reports/{year-month}/*.md 报告是否生成
10. 不存在 → 启动子 agent 执行 agent-report-render
```

### 子 Agent 调用示例

```javascript
// 启动阶段1子agent
Agent(
  prompt: "执行 /agent-report-broad-search 2026-04",
  subagent_type: "general-purpose"
)

// 等待完成后读取结果，继续下一阶段
```

## 阶段检查点

| 阶段 | 检查文件 | 跳过条件 |
|------|----------|----------|
| 1. broad-search | `reports/{y-m}/index.json` | total_count >= 100 |
| 2. screen | `reports/{y-m}/candidates/` | candidates 数量 >= 10 |
| 3. deep-dive | `reports/{y-m}/deep_dive/` | deep_dive 数量 >= 10 |
| 4. score | `reports/{y-m}/ranking.json` | 文件存在 |
| 5. render | `reports/{y-m}/*-AI-Agent-案例报告.md` | 文件存在 |

## 子 Agent 调用流程（伪代码）

```
function execute_phase(phase_name, skill_name, year_month):
    // 检查是否需要执行
    if is_phase_complete(phase_name, year_month):
        print(f"阶段 {phase_name} 已完成，跳过")
        return

    // 启动子 agent 执行
    print(f"启动阶段 {phase_name}...")
    result = await Agent(
        description=f"执行 {skill_name} {year_month}",
        prompt=f"你是一个专业的 AI Agent 案例报告研究员。请执行以下任务：

1. 激活 gstack 浏览器: /open-gstack-browser
2. 执行技能: /{skill_name} {year_month}
3. 确保所有输出保存到 reports/{year_month}/ 目录
4. 执行完成后，报告已处理的候选数量和输出文件列表",
        subagent_type="general-purpose"
    )

    // 验证输出
    if not is_phase_complete(phase_name, year_month):
        throw error(f"阶段 {phase_name} 执行失败")

// 主流程
async function main():
    year_month = "2026-04"

    execute_phase("1-broad-search", "agent-report-broad-search", year_month)
    execute_phase("2-screen", "agent-report-screen", year_month)
    execute_phase("3-deep-dive", "agent-report-deep-dive", year_month)
    execute_phase("4-score", "agent-report-score", year_month)
    execute_phase("5-render", "agent-report-render", year_month)

    print("全部阶段完成！")
```

## Sub Skills

| Skill | 职责 |
|-------|------|
| `/agent-report-broad-search` | 阶段1: 广度搜索多信源 |
| `/agent-report-screen` | 阶段2: 初筛 TOP 10 |
| `/agent-report-deep-dive` | 阶段3: 深度剖析 TOP 10 |
| `/agent-report-score` | 阶段4: 评分排序 TOP 5 |
| `/agent-report-render` | 阶段5: 渲染最终报告 |
