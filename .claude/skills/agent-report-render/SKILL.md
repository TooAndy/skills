---
name: agent-report-render
description: Use when need to generate AI Agent case report in Markdown format from ranked TOP 5 cases
---

# Agent Report Render

阶段 5：从 TOP 5 排序结果生成最终 Markdown 报告。

## 硬性约束

1. **必须等阶段4完成** - 只有 ranking.json 存在才能开始
2. **必须生成最终报告** - 路径必须是 YYYY-MM-AI-Agent-案例报告.md

## 来源标注要求

**警告**: 最终报告必须标注信息来源，否则读者无法判断内容可信度。

每个案例必须包含：
1. **主要来源** - GitHub/官网 URL
2. **辅助来源** - 文档/博客 URL（如果有）
3. **数据来源** - stars、points 等数据必须来自实际提取

## 输入检查

读取 `reports/{year}-{month}/ranking.json`，检查：
- 必须存在
- 必须包含 5 个 rankings
- 如果不存在，报错要求重新执行阶段4

## 输入

- `reports/{year}-{month}/ranking.json` - TOP 5 排序结果
- `reports/{year}-{month}/deep_dive/` - TOP 10 深度剖析（用于 TOP 5 的完整内容）

## 输出

- `reports/{year}-{month}/YYYY-MM-AI-Agent-案例报告.md` - 最终报告

## 报告模板

```markdown
# {{ year }}-{{ month }} AI Agent 案例月度报告

> 生成时间: {{ generated_at }}
> 信源: Hacker News / GitHub Trending / 产品官网 / 行业媒体 / 技术博客

---

## 本月 TOP 案例速览

{{ total_cases }} 个案例入选，聚焦于 {{ focus_areas }}

| # | 案例 | 类型 | 亮点 | 评级 | 来源验证 |
|---|------|------|------|------|----------|
| 1 | {{ name }} | {{ type }} | {{ highlight }} | ⭐⭐⭐⭐⭐ | ✅/⚠️ |

---

{% for case in cases %}
## {{ loop.index }}. {{ case.name }}

**产品链接**: [{{ case.url }}]({{ case.url }})
**开源地址**: {{ case.github_url or "闭源商业产品" }}
**发布时间**: {{ case.published_at }}
**社区热度**: {{ case.stars or "N/A" }}
**来源验证**: {{ source_verified_status }}

### 来源信息

- 主要来源: [URL] - [提取的信息]
- 辅助来源: [URL] - [提取的信息]

### 1. 业务与场景定义

**解决什么问题**: {{ case.business.problem }}
**场景类型**: {{ case.business.scenario_type }}
**核心价值**: {{ case.business.core_value }}
**替代方案对比**: {{ case.business.alternative }}

### 2. 技术架构与能力

**Agent 角色与编排**: {{ case.architecture.roles }}
**编排框架**: {{ case.architecture.framework }}
**基座模型**: {{ case.architecture.model }}
**工具集**: {{ case.architecture.tools }}
**记忆机制**: {{ case.architecture.memory }}

### 3. 数据流与工作流

**触发机制**: {{ case.workflow.trigger }}
**决策逻辑**: {{ case.workflow.decision }}
**状态管理**: {{ case.workflow.state }}
**输出形式**: {{ case.workflow.output }}

### 4. 工程落地与运维

**部署方式**: {{ case.engineering.deployment }}
**性能指标**: {{ case.engineering.performance }}
**监控可观测性**: {{ case.engineering.monitoring }}
**容错降级**: {{ case.engineering.fault_tolerance }}

### 5. 风险与合规

**已知问题/局限**: {{ case.risks.known_issues }}
**幻觉控制**: {{ case.risks.hallucination_control }}
**数据安全**: {{ case.risks.data_security }}
**高风险操作**: {{ case.risks.high_risk_operations }}

### 优缺点总结

**优点**:
{{ case.advantages }}

**缺点/风险**:
{{ case.disadvantages }}

### 团队可借鉴点

**可以直接用的**: {{ case.takeaways.can_use }}
**需要谨慎借鉴的**: {{ case.takeaways.need_caution }}
**警示**: {{ case.takeaways.warning }}

---

{% endfor %}

## 本月总结

- 本月共收录 {{ cases|length }} 个案例
- 类型分布: {{ type_distribution }}
- 整体趋势: {{ trend_summary }}

## 下月关注

- {{ next_month_focus_1 }}
- {{ next_month_focus_2 }}
- {{ next_month_focus_3 }}

---

## 报告说明

本报告所有信息均来自公开数据源：
- 主要来源：GitHub README、产品官网
- 辅助来源：官方文档、技术博客
- 社区数据：GitHub stars、HN points 等实际数据

**来源验证状态**:
- ✅ 已验证：信息来源明确，内容与来源一致
- ⚠️ 部分验证：来源存在但内容可能不完整
- ❌ 未验证：缺少来源信息，内容基于推测

如需进一步验证，请点击每个案例的"产品链接"访问原始来源。
```

## 输出

生成 `reports/{year}-{month}/YYYY-MM-AI-Agent-案例报告.md`。

## Usage

```bash
/agent-report-render 2026-04
```