---
name: wechat-article-scraper
description: Use when scraping WeChat public account articles from album pages and saving to local files
---

# WeChat Article Scraper

从微信公众号相册页面抓取文章列表并保存到本地文件。

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

## 功能

- 访问微信公众号相册页面 (mp.weixin.qq.com)
- 抓取指定月份的文章列表（标题、日期、链接）
- **抓取每篇文章的完整正文内容**
- 将结果保存为 Markdown 文件（完整原文 + 可点击链接）

## 目录结构

```
wechat-article-scraper/
├── SKILL.md                    # 本文档
└── scripts/
    ├── extract_articles.py     # Python提取脚本（从HTML提取文章列表）
    ├── fetch_article_content.py # Python抓取脚本（抓取文章完整内容）
    └── scrape_wechat.sh        # Bash一键抓取脚本
```

## 与 agent-report 配合使用

当被 `agent-report-broad-search` 调用时，输出到报告目录：

```
reports/{year-month}/wechat_articles/{公众号名}_{专栏名}/
├── index.json                  # 文章列表索引
└── {文章id}.md                # 各篇文章内容
```

示例：
```
reports/2026-04/wechat_articles/机器之心_AI开源项目/
├── index.json
├── abc123.md
├── def456.md
└── ...
```

## 使用方式

### 方式一：Bash脚本（推荐）

```bash
# 完整用法
./scripts/scrape_wechat.sh <url> <output_folder> <year-month> <account_name>

# 示例 - 输出到报告目录
./scripts/scrape_wechat.sh "https://mp.weixin.qq.com/mp/appmsgalbum?__biz=..." "reports/2026-04/wechat_articles/机器之心_AI开源项目" "2026-04" "机器之心_AI开源项目"
```

**输出**:
- `index.json` - 文章列表索引
- `{文章id}.md` - 各篇文章内容

### 方式二：Python脚本（灵活）

```bash
# 查看帮助
python3 scripts/extract_articles.py

# 提取所有文章到JSON
python3 scripts/extract_articles.py /tmp/wechat_html.txt output.json

# 提取并筛选月份
python3 scripts/extract_articles.py /tmp/wechat_html.txt output.json 2026 4
```

### 方式三：手动（完整控制）

```bash
# 1. 使用 gstack browse 访问页面并滚动
$B goto "<url>"
for i in {1..15}; do $B scroll; sleep 0.5; done
$B wait --networkidle

# 2. 保存HTML
$B html > /tmp/wechat_html.txt

# 3. 使用Python脚本提取
python3 scripts/extract_articles.py /tmp/wechat_html.txt articles.json 2026 4
```

## 工作流程

1. **访问页面** - 使用 gstack browse 导航到相册页面
2. **滚动加载** - 多次滚动页面触发懒加载，加载所有历史文章
3. **保存HTML** - 使用 `$B html > /tmp/wechat_html.txt` 保存完整页面源码
4. **提取数据** - 运行 `extract_articles.py` 脚本从HTML中提取文章数据
5. **过滤保存** - 筛选目标月份的文章，保存为 Markdown

## 关键技术点

### 从HTML提取文章URL

微信公众号相册页面的HTML中，每个文章项是 `<li class="album__list-item">` 标签，包含：
- `data-link`: 文章的真实URL（格式：`http://mp.weixin.qq.com/s?__biz=...&mid=...&idx=...&sn=...`）
- `data-title`: 文章标题
- `data-msgid`: 文章mid
- `data-itemidx`: 文章idx
- 子元素 `<span class="js_article_create_time">`: 发布日期

### 日期计算规则

如果当前日期为 `2026-04-28`，计算方式：
- 昨天 = 当天 - 1 天
- 前天 = 当天 - 2 天
- N天前 = 当天 - N 天
- 1周前 = 当天 - 7 天
- MM/DD = {当前年份}-MM-DD

## 输出格式

### 单篇文章内容 (wechat_articles/{公众号}_{专栏}/{文章id}.md)

```markdown
# {文章标题}
**来源**: {公众号名称} - {专栏名称}
**日期**: {YYYY-MM-DD}
**链接**: {原文链接}

---
{正文内容}
```

### 文章索引 (wechat_articles/{公众号}_{专栏}/index.json)

```json
{
  "account": "{公众号名称}",
  "column": "{专栏名称}",
  "album_url": "{专辑URL}",
  "scrape_date": "{YYYY-MM-DD}",
  "article_count": {数量},
  "articles": [
    {
      "id": "{文章id}",
      "title": "{文章标题}",
      "url": "{文章链接}",
      "date": "{YYYY-MM-DD}",
      "local_path": "{文章id}.md"
    }
  ]
}
```

## 示例

抓取机器之心AI应用观察专栏 2026年4月文章：

```bash
cd .claude/skills/wechat-article-scraper
./scripts/scrape_wechat.sh "https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzA3MzI4MjgzMw==&..." "reports/2026-04/wechat_articles/机器之心_AI应用观察" "2026-04" "机器之心_AI应用观察"
```

输出文件：
```
reports/2026-04/wechat_articles/机器之心_AI应用观察/
├── index.json          # 文章索引
├── abc123.md          # 文章1
├── def456.md          # 文章2
└── ...
```

## 技术要点

- 使用 gstack browse 的 headless Chromium 浏览器
- HTML中的 `data-link` 属性包含真实文章URL，可直接使用
- 文章按 `mid` 降序排列（ newest first）
- 需要滚动多次触发懒加载加载所有文章
- `extract_articles.py` 支持灵活过滤和输出格式
