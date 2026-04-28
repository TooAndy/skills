---
name: agent-report-screen
description: Use when need to screen candidates from broad search results to select TOP 10 - Phase 2 of report generation
---

# Agent Report Screen

阶段 2：从阶段1收集的候选中，初筛出 TOP 10 最佳候选。

## 前置依赖

**gstack** 是必需的浏览器自动化工具，通过 `/open-gstack-browser` skill 提供。

### 激活流程

```
1. 尝试激活 gstack skill: /open-gstack-browser
2. 如果 skill 不可用或激活失败，尝试安装: /setup-gstack
3. 如果安装也失败，报错要求手动安装
```

### 手动安装（如自动激活失败）

```bash
# 方式一：使用 skill 安装
/setup-gstack

# 方式二：手动安装（参考 gstack 官方文档）
# 安装后验证: gstack --version
```

## 硬性约束

1. **必须等阶段1完成** - 只有 index.json 中 total_count >= 100 才能开始
2. **必须筛选 10 个** - 不能少，类型尽量分散
3. **必须全部写入 candidates/**

## 筛选信息验证要求

**警告**: 仅基于 index.json 中的 abstract 进行筛选会导致选出不合适或信息不足的案例。

### 验证流程

对每个进入 TOP 10 候选名单的案例，执行以下验证：

```
1. 使用 gstack browse 打开候选的 URL（GitHub 或官网）
2. 验证：stars/points 数据是否准确
3. 验证：abstract 描述是否与实际相符
4. 验证：是否有足够的技术信息可挖取
5. 根据验证结果决定是否进入 TOP 10
```

### 验证标准

| 验证项 | 要求 |
|--------|------|
| URL 可访问性 | GitHub/官网必须可正常访问 |
| stars/points 准确性 | 与实际数据对比，误差不超过 10% |
| abstract 一致性 | 描述与实际产品功能相符 |
| 技术信息充足性 | 有 README、文档或官网可获取技术信息 |

### 筛选标准

| 维度 | 权重 | 说明 |
|------|------|------|
| 相关度 | 30% | 与 AI Agent 的相关性 |
| 热度 | 25% | stars / points / 讨论度 |
| 时效性 | 20% | 发布时间（越新越好）|
| 可分析性 | 15% | 是否有足够的技术信息可挖取（必须通过浏览验证） |
| 独特性 | 10% | 与已有候选的差异化 |

## 输入检查

读取 `reports/{year}-{month}/index.json`，检查：
- `total_count >= 100` 才能继续
- 如果 < 100，报错要求重新执行阶段1

## 重复案例排除

**重要**: 如果某案例在上月报告中已详细剖析过，本月应区分处理：

### 查重流程

1. **扫描历史报告**: 读取 `reports/` 目录下所有过往月份的报告
2. **建立已选案例库**: 记录历史已选的案例名称、GitHub URL
3. **分类处理**:

| 情况 | 处理方式 |
|------|----------|
| 案例完全相同 | **排除**，不进入 TOP 10 |
| 案例有重大更新 | **可入选**，但聚焦于更新点，而非重复介绍 |
| 案例是竞品/同类新秀 | **可入选**，需对比差异化 |

### 差异化评分

对于已在历史报告中出现过的案例：
- **全新案例**: 独特性得分 100%
- **有重大更新的历史案例**: 独特性得分 70%（重点评估更新点）
- **无更新的历史案例**: 独特性得分 0%（直接排除）

### 重大更新判断标准

以下情况可视为"重大更新"：
- 大版本号升级（如 v1.0 → v2.0）
- 新增核心功能（官网/文档明确标注）
- 重大架构变更
- 新的使用场景突破

### 示例

```
历史报告: 2026-03 包含 OpenCode
本月候选: OpenCode v2.0 发布

处理: 可入选 TOP 10，但剖析重点:
- 相比 v1.0 的核心更新
- 新功能的技术架构变化
- 不再重复介绍 v1.0 已有的基础功能
```

## 工作目录

```
reports/{year}-{month}/
├── index.json              # 输入: 100+ 条候选
└── candidates/            # 输出: TOP 10 候选
    ├── candidate_001.json
    └── ...
```

## 筛选流程

1. **检查**: 确认 index.json total_count >= 100
2. **浏览**: 快速浏览所有候选的 title + abstract
3. **预选**: 标记 A/B/C 等级
4. **验证**: 对预选为 A 的候选，使用 browse 访问 URL 验证信息
5. **调整**: 根据验证结果调整等级
6. **选择 TOP 10**: 优先选 A 类（已验证），不够时从 B 类补充
7. **类型分散**: 确保 10 个案例类型尽量不同
8. **写入 candidates/**: 每条 TOP 10 候选写入单独文件

## 输出格式

每条候选输出为 `candidates/candidate_XXX.json`:

```json
{
  "id": "candidate_001",
  "rank": 1,
  "name": "Project/Product Name",
  "url": "https://...",
  "source": "来源",
  "published_at": "2026-04",
  "stars": "12k",
  "points": 1234,
  "quick_summary": "2-3句话描述这是什么、解决什么、为什么值得关注",
  "screening_reason": "为什么进入 TOP 10（基于浏览验证）",
  "screening_notes": "备注：可能的优点/风险点",
  "deep_dive_path": "deep_dive/candidate_001.md",
  "verified": true,
  "verification_sources": ["https://github.com/xxx", "https://yyy.com"]
}
```

## 输出

在 `reports/{year}-{month}/candidates/` 生成 10 个候选文件。

## Usage

```bash
/agent-report-screen 2026-04
```