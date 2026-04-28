---
name: agent-report-score
description: Use when need to rank and select TOP 5 from TOP 10 candidates for AI Agent case report
---

# Agent Report Score

阶段 4：从 10 个候选案例中综合评估，选出 TOP 5 并输出排序理由。

## 硬性约束

1. **必须等阶段3完成** - 只有 deep_dive/ 中有 10 份深度剖析才能开始
2. **必须选出 5 个** - 最终报告就是 TOP 5
3. **必须输出 ranking.json**

## 来源验证要求

**警告**: 如果 deep_dive/ 中的内容未经实际浏览验证，排序结果将不可信。

### 验证流程

评分前，必须验证每个 deep_dive 文件的来源信息：

```
1. 打开 deep_dive/candidate_XXX.md
2. 检查是否存在"来源信息"部分
3. 检查是否包含真实 URL 链接
4. 如果来源信息缺失或可疑，标记该案例为"未验证"
5. 对未验证的案例，降低评分权重
```

### 信息完整度评分标准

| 等级 | 标准 |
|------|------|
| 完整 | 有主要来源 + 辅助来源链接，内容与链接相符 |
| 部分 | 有来源链接，但内容可能不完整 |
| 可疑 | 无来源链接，或内容与已知信息矛盾 |
| 未验证 | 无法确认来源，需要重新浏览验证 |

### 降级规则

如果 deep_dive 缺少来源信息：
- 信息完整度得分 × 0.5
- 架构完整性得分 × 0.7（因为无法确认架构真实性）

## 输入检查

读取 `reports/{year}-{month}/deep_dive/`，检查：
- 必须有 10 份深度剖析文件
- 如果不足 10 个，报错要求重新执行阶段3

## 输入

- `reports/{year}-{month}/candidates/` - 10 个候选案例（快速摘要）
- `reports/{year}-{month}/deep_dive/` - 10 份深度剖析报告（5-layer 框架）

## 输出

- `reports/{year}-{month}/ranking.json` - TOP 5 排序结果

## 评分维度

| 维度 | 权重 | 说明 |
|------|------|------|
| 技术落地性 | 30% | 团队能否直接使用或借鉴其架构（需要来源验证） |
| 架构完整性 | 20% | 技术架构是否清晰、可学习（需要来源验证） |
| 信息完整度 | 15% | 深度剖析是否充分，**来源是否可查** |
| 社区活跃度 | 15% | 项目是否活跃、持续更新 |
| 风险可控性 | 10% | 已知风险是否明确、有缓解措施 |
| 时效性 | 10% | 是否为当月最新案例 |

## 评分规则

1. **不做绝对打分** - 只做相对排序
2. **综合权衡** - 不是单一维度最优，而是多维度平衡
3. **有据可查** - 每条排序理由都要引用 deep_dive 中的具体信息
4. **来源验证** - 无来源的内容不能作为排序依据

## Incident 引用机制

以下 incident 案例作为"风险引用"，影响评分：

| Incident 案例 | 影响 |
|---------------|------|
| AI agent 删库事故 | 风险可控性 -20% 如果涉及高风险操作但无缓解措施 |
| AI agent 发黑料 | 风险可控性 -20% 如果涉及内容生成但无审核机制 |
| AI agent shame maintainer | 技术落地性 -10% 如果涉及自动化提交但无人工 review |

## 输出格式

### ranking.json

```json
{
  "rankings": [
    {
      "rank": 1,
      "id": "candidate_001",
      "name": "案例名称",
      "url": "https://...",
      "type": "AI 编程 agent",
      "stars": "53.9k",
      "source_verified": true,
      "ranking_reason": {
        "technical_feasibility": "引用自 deep_dive 中的具体内容 + 来源验证",
        "architecture_completeness": "引用自 deep_dive 中的具体内容 + 来源验证",
        "information_completeness": "有/无来源链接验证",
        "community_activity": "实际数据（GitHub stars 实际值）",
        "risk_controllability": "引用自 deep_dive + incident 引用",
        "timeliness": "实际发布时间"
      },
      "comprehensive_judgment": "综合判断"
    }
  ],
  "excluded": [
    {
      "id": "candidate_006",
      "name": "案例名称",
      "reason": "为什么不选（包括来源验证问题）"
    }
  ]
}
```

### Markdown 格式

```markdown
## 案例排序

### 1. [案例名称]
**链接**: [URL]
**类型**: AI 编程 agent / 通用 Agent 平台 / 多Agent框架 / ...
**热度**: GitHub stars / HN points
**来源验证**: [完整/部分/可疑/未验证]

**排序理由**:
- 技术落地性: [分析，引用 deep_dive 内容]
- 架构完整性: [分析，引用 deep_dive 内容]
- 信息完整度: [分析，评估来源可信度]
- 社区活跃度: [分析]
- 风险可控性: [分析，引用 incident]
- 时效性: [分析]

**综合判断**: [为什么排第一]

---

### 2-5. [同理]
```

## 注意事项

1. **TOP 5 选择标准**: 选出来的是"最适合团队借鉴，最值得深入了解"的案例
2. **不选的理由**: 落选的 5 个也要简短说明为什么不选
3. **差异化**: 确保 TOP 5 之间有差异化，不要全是同类型案例
4. **来源标注**: 每个排序理由必须标注信息来源

## Usage

```bash
/agent-report-score 2026-04
```