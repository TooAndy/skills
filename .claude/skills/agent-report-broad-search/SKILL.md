---
name: agent-report-broad-search
description: Use when need to perform broad search for AI Agent cases from multiple sources - Phase 1 of report generation
---
# Agent Report Broad Search

阶段 1：从多个信源广度搜索，从成千上万的信息中收集候选案例。

## 前置依赖

**gstack** 是必需的浏览器自动化工具。如果未安装，会自动尝试安装。

### 安装检查流程

```
1. 检查 gstack 是否可用: gstack --version
2. 如果不可用，尝试安装: /setup-gstack
3. 如果安装失败，报错要求手动安装
```

### 手动安装 gstack（如自动安装失败）

```bash
# 方式一：使用 skill 安装
/setup-gstack

# 方式二：手动安装（参考 gstack 官方文档）
# 安装后验证: gstack --version
```

## 硬性约束（必须遵守）

1. **每条候选必须立即落盘** - 获取一条就写入 index.json，不要等到最后一起写
2. **最低目标 100 条** - 只有达到 100 条才能进入下一阶段
3. **理想目标 200 条** - 尽量达到 200 条
4. **不允许提前停止** - 除非已达到目标数量，否则不能因为"感觉够了"就停止
5. **逐条摘要** - 每条候选必须包含 2-3 句摘要

## 信息来源要求

**警告**: 禁止基于训练数据生成 abstract。摘要必须来自实际浏览的内容。

### 摘要提取规则

每条候选的 abstract 必须从以下来源提取或概括：

- GitHub README 的项目描述
- 产品官网的 tagline
- HN/论坛的讨论内容
- 中文文章的产品介绍

**禁止**:

- ❌ 禁止基于项目名称"推断" abstract
- ❌ 禁止使用训练数据中的知识填充 abstract
- ❌ 禁止编造 stars、points 数据

### 数据验证

| 字段         | 验证方式                 |
| ------------ | ------------------------ |
| stars        | 从 GitHub 页面实际提取   |
| points       | 从 HN/论坛实际提取       |
| published_at | 从页面实际提取，不能猜测 |

## 工作目录

```
reports/{year-month}/
├── index.json              # 输出: 逐条写入，100-200+ 条候选
├── raw_articles/           # 英文/HN文章缓存（可选）
└── wechat_articles/        # 微信公众号文章内容缓存（必须保存）
    ├── 机器之心_AI产业动态/
    ├── 机器之心_AI开源项目/
    ├── 量子位_2026科技圈都在关注/
    └── ...
```

**重要**: 中文信源（微信公众号）的文章内容**必须保存到本地**，避免重复爬取。

## 严格流程

```
1. 初始化 index.json (空数组)
2. 遍历英文信源:
   3. 访问信源 (使用 gstack browse)
   4. 获取每条候选:
      5. 提取基本信息 (title, url, source, points/stars, etc.)
      6. 使用 gstack browse 打开候选 URL，提取真实信息
      7. 生成 2-3 句摘要（基于实际浏览内容）
      8. 立即 append 到 index.json
      9. 更新 total_count
   10. 检查 total_count >= 100?
      - 是: 可以继续或停止
      - 否: 继续下一个信源
3. 中文信源（必须执行）:
   4. 使用 wechat-article-scraper 爬取机器之心公众号各个专栏
   5. 使用 wechat-article-scraper 爬取量子位公众号各个专栏
   6. 提取文章中的产品信息，补充到 index.json
4. 返回 index.json
```

**关键**:

- 不要等所有信源都搜完再写 index.json，要**逐条 append**
- 每次提取候选后，立即用 browse 访问 URL 验证信息
- **必须执行中文信源搜索**，不能跳过

## 信源与策略

### 英文信源（必须浏览）

| 信源            | 搜索策略                                               | 目标数量 |
| --------------- | ------------------------------------------------------ | -------- |
| Hacker News     | https://hn.algolia.com/?q=AI+agent&df=story            | 50-100   |
| GitHub Trending | https://github.com/trending?q=AI+agent                 | 30-50    |
| GitHub Search   | https://github.com/search?q=AI+agent&type=repositories | 50-100   |
| Reddit          | r/LocalLLaMA 搜索 AI Agent                             | 20-30    |
| Product Hunt    | AI Agent 相关产品                                      | 20-30    |

### 中文信源（必须爬取）

中文信源包含两个高质量公众号：**机器之心** 和 **量子位**，都是 AI 领域专业媒体。

#### 机器之心公众号

使用 `/wechat-article-scraper` skill 爬取以下专栏：

| 专栏名称      | 专辑 ID             | 链接                                                                                                             |
| ------------- | ------------------- | ---------------------------------------------------------------------------------------------------------------- |
| AI产业动态    | 3394925372672114699 | [链接](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzA3MzI4MjgzMw==&action=getalbum&album_id=3394925372672114699) |
| AI开源项目    | 3553007472372318212 | [链接](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzA3MzI4MjgzMw==&action=getalbum&album_id=3553007472372318212) |
| AI研究前沿    | 3661496204539314177 | [链接](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzA3MzI4MjgzMw==&action=getalbum&album_id=3661496204539314177) |
| AI应用观察    | 3538614658318434311 | [链接](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzA3MzI4MjgzMw==&action=getalbum&album_id=3538614658318434311) |
| AI好好用      | 4006817282595815425 | [链接](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzA3MzI4MjgzMw==&action=getalbum&album_id=4006817282595815425) |
| AIxiv专栏2026 | 4328536051397804037 | [链接](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzA3MzI4MjgzMw==&action=getalbum&album_id=4328536051397804037) |

#### 量子位公众号

使用 `/wechat-article-scraper` skill 爬取以下专栏：

| 专栏名称          | 专辑 ID             | 链接                                                                                                             |
| ----------------- | ------------------- | ---------------------------------------------------------------------------------------------------------------- |
| 2026科技圈都在关注 | 4328332372740784146 | [链接](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzIzNjc1NzUzMw==&action=getalbum&album_id=4328332372740784146) |
| 2026学术圈都在关注 | 4409896429188497412 | [链接](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzIzNjc1NzUzMw==&action=getalbum&album_id=4409896429188497412) |

#### 中文信源执行流程

1. **机器之心**: 使用 `/wechat-article-scraper` skill 依次爬取上述 6 个专栏，获取文章列表
2. **量子位**: 使用 `/wechat-article-scraper` skill 依次爬取上述 2 个专栏，获取文章列表
3. **保存文章列表**: 将专栏文章列表保存到 `wechat_articles/{公众号名}_{专栏名}/index.json`
4. **逐个访问文章内容**:
   - 使用 gstack browse 访问每篇文章的 URL
   - 提取文章标题、发布时间、正文内容（AI Agent 相关段落）
   - 将文章内容保存到 `wechat_articles/{公众号名}_{专栏名}/{文章id}.md`
   - 提取 AI Agent 相关产品/项目信息
   - 生成 2-3 句摘要
   - 立即 append 到 index.json
5. 重点关注: 深度评测、架构解析、产品介绍

**文章内容必须保存到本地**，格式:
```markdown
# {文章标题}
**来源**: {公众号名} - {专栏名}
**日期**: {YYYY-MM-DD}
**链接**: {原文链接}

---
{正文内容}
```

**注意**: 如果某个信源返回 403 或超时，继续下一个信源，但必须尝试至少 3 次不同方式访问。

## 抓取格式（逐条写入）

每条候选取以下字段，**立即 append 到 index.json**：

```json
{
  "id": "hn_001",
  "title": "Article/Project Title",
  "url": "https://...",
  "source": "Hacker News / 机器之心 / 量子位",
  "published_at": "2026-04",
  "points": 1234,
  "stars": null,
  "comments": 456,
  "abstract": "2-3句话快速摘要: 从实际页面提取的内容",
  "relevance_score": "high/medium/low",
  "local_path": "raw_articles/hn_001.md",
  "source_urls": ["https://github.com/xxx", "https://mp.weixin.qq.com/xxx"]
}
```

**中文文章 local_path 格式**: `wechat_articles/{公众号名}_{专栏名}/{文章id}.md`

**示例**:
- `wechat_articles/机器之心_AI开源项目/abc123.md`
- `wechat_articles/量子位_2026科技圈都在关注/def456.md`

## 摘要生成规则

每条候选取 title + context，用 2-3 句话描述：

1. **这是什么？** 从页面实际提取的项目描述
2. **解决什么？** 从页面实际提取的功能描述
3. **为什么值得关注？** 从页面提取的热度数据或用户评价

## 渐进式检查点

搜索过程中每完成一个信源就检查一次：

- total_count >= 100? → 可以结束或继续
- total_count < 100? → 必须继续下一个信源

## 输出

生成 `reports/{year-month}/index.json`，包含 100-200+ 条候选案例。

**index.json 格式**:

```json
{
  "month": "2026-04",
  "created_at": "2026-04-28",
  "total_count": 150,
  "sources_searched": ["Hacker News", "GitHub Trending", "机器之心公众号", "量子位", ...],
  "candidates": [
    {...第一条...},
    {...第二条...},
    ...
  ]
}
```

## Usage

```bash
/agent-report-broad-search 2026-04
```

**重要**: 执行过程中不要输出多余的废话，直接执行搜索和写入。

**核心原则**: 每条候选的 abstract 和数据必须来自实际浏览，禁止基于训练数据编造。
