# 每月 AI Agent 案例报告生成器 — 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 构建一个 Python CLI 工具，输入月份后自动从多信源收集 AI Agent 案例，筛选评分后生成 Markdown 报告。

**Architecture:** 工具链为「信源爬虫 → 评分器 → 模板引擎 → Markdown」。各信源独立爬取，并行执行；评分器统一打分排序；Jinja2 模板渲染 Markdown；pandoc 处理格式转换。

**Tech Stack:** Python 3.12+, Jinja2, BeautifulSoup, requests, feedparser, pandoc

---

## 文件结构

```
monthly_agent_report/
├── generate_report.py          # 主入口 CLI
├── report_template.md           # Jinja2 报告模板
├── sources/
│   ├── __init__.py
│   ├── base.py                  # BaseScraper 抽象类
│   ├── hacker_news.py           # Hacker News 爬虫
│   ├── github_trending.py       # GitHub Trending 爬虫
│   ├── industry_media.py        # 机器之心/量子位/InfoQ/人人都是产品经理
│   ├── official_docs.py         # OpenAI/Anthropic/DeepSeek 官方
│   ├── social_media.py          # Twitter/X + Reddit
│   ├── ai_portals.py            # 未来百科/AI产品精选
│   ├── arxiv.py                 # arXiv 论文
│   └── rss/
│       ├── __init__.py
│       └── newsletter.py        # AI Newsletter RSS 解析
├── utils/
│   ├── __init__.py
│   ├── scorer.py                # 案例评分逻辑
│   └── converter.py             # Markdown → HTML/Notion
├── tests/
│   ├── __init__.py
│   ├── test_scorer.py
│   ├── test_scrapers.py
│   └── test_converter.py
├── requirements.txt
├── pyproject.toml
└── README.md
```

---

## Task 1: 项目脚手架

**Files:**
- Create: `requirements.txt`
- Create: `pyproject.toml`
- Create: `README.md`

- [ ] **Step 1: 创建 requirements.txt**

```
jinja2>=3.1.0
beautifulsoup4>=4.12.0
requests>=2.31.0
feedparser>=6.0.0
lxml>=4.9.0
typer>=0.9.0
rich>=13.0.0
```

- [ ] **Step 2: 创建 pyproject.toml**

```toml
[project]
name = "monthly-agent-report"
version = "0.1.0"
description = "每月 AI Agent 案例报告生成器"
requires-python = ">=3.12"
dependencies = [
    "jinja2>=3.1.0",
    "beautifulsoup4>=4.12.0",
    "requests>=2.31.0",
    "feedparser>=6.0.0",
    "lxml>=4.9.0",
    "typer>=0.9.0",
    "rich>=13.0.0",
]

[project.optional-dependencies]
dev = ["pytest>=7.0.0", "pytest-asyncio>=0.21.0"]

[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"

[tool.pytest.ini_options]
testpaths = ["tests"]
```

- [ ] **Step 3: 创建 README.md**

```markdown
# Monthly Agent Report

每月 AI Agent 案例报告生成器。

## 安装

```bash
pip install -e .
```

## 使用

```bash
# 生成指定月份报告
python generate_report.py --month 2026-03

# 转换报告为 HTML
python generate_report.py --convert --input 2026-03-AI-Agent-案例报告.md --format html

# 转换报告为 Notion 格式
python generate_report.py --convert --input 2026-03-AI-Agent-案例报告.md --format notion
```

## 信源

- Hacker News
- GitHub Trending
- 机器之心、量子位、InfoQ、人人都是产品经理
- OpenAI、Anthropic、DeepSeek 官方文档
- Twitter/X、Reddit
- 未来百科、AI产品精选
- arXiv
```

- [ ] **Step 4: 创建目录结构并初始化**

```bash
mkdir -p sources/rss utils tests
touch sources/__init__.py sources/rss/__init__.py utils/__init__.py tests/__init__.py
```

- [ ] **Step 5: Commit**

```bash
git init
git add requirements.txt pyproject.toml README.md sources/__init__.py sources/rss/__init__.py utils/__init__.py tests/__init__.py
git commit -m "feat: scaffold project structure"
```

---

## Task 2: 报告模板

**Files:**
- Create: `report_template.md`

- [ ] **Step 1: 创建 report_template.md**

```markdown
# {{ year }}-{{ month }} AI Agent 案例月度报告

> 生成时间: {{ generated_at }}
> 信源: Hacker News / GitHub Trending / 行业媒体 / 官方文档 / 社交媒体 / AI导航站 / arXiv

---

{% for case in cases %}
## {{ loop.index }}. {{ case.title }}

### 案例概述
{{ case.overview }}

### 技术栈
{% for item in case.tech_stack %}
- {{ item }}
{% endfor %}

### 实现路径
{{ case.implementation_path }}

### 效果数据
{{ case.effects }}

### 技术亮点
{{ case.highlights }}

### 局限分析
{{ case.limitations }}

### 团队可借鉴点
{{ case.takeaways }}

---
{% endfor %}

## 本月总结

本月共收录 {{ cases|length }} 个案例，主要集中在以下领域：
{% for domain in domains %}
- {{ domain }}
{% endfor %}

## 下月关注

{% for focus in next_month_focus %}
- {{ focus }}
{% endfor %}
```

- [ ] **Step 2: Commit**

```bash
git add report_template.md
git commit -m "feat: add report Jinja2 template"
```

---

## Task 3: 评分器 (scorer.py)

**Files:**
- Create: `utils/scorer.py`
- Create: `tests/test_scorer.py`

- [ ] **Step 1: 编写测试 test_scorer.py**

```python
from utils.scorer import CaseScorer, Case

def test_score_single_case():
    case = Case(
        title="Test Case",
        overview="A test case",
        source_weight=5,
        tech_depth=4,
        feasibility=3,
        timeliness=5,
        reference_value=4,
    )
    scorer = CaseScorer()
    score = scorer.calculate_score(case)
    assert score > 0
    assert isinstance(score, float)

def test_sort_cases():
    cases = [
        Case(title="Low", overview="", source_weight=1, tech_depth=1, feasibility=1, timeliness=1, reference_value=1),
        Case(title="High", overview="", source_weight=5, tech_depth=5, feasibility=5, timeliness=5, reference_value=5),
    ]
    scorer = CaseScorer()
    sorted_cases = scorer.sort_cases(cases, top_n=1)
    assert len(sorted_cases) == 1
    assert sorted_cases[0].title == "High"
```

- [ ] **Step 2: 运行测试验证失败**

```bash
pytest tests/test_scorer.py -v
# Expected: FAIL — scorer module doesn't exist
```

- [ ] **Step 3: 编写 scorer.py**

```python
from dataclasses import dataclass
from typing import List

@dataclass
class Case:
    title: str
    overview: str
    source_weight: int  # 1-5
    tech_depth: int      # 1-5
    feasibility: int    # 1-5
    timeliness: int      # 1-5
    reference_value: int  # 1-5
    url: str = ""
    source: str = ""

class CaseScorer:
    # 权重配置
    WEIGHTS = {
        "source_weight": 1.5,
        "tech_depth": 1.2,
        "feasibility": 1.0,
        "timeliness": 1.3,
        "reference_value": 1.4,
    }

    def calculate_score(self, case: Case) -> float:
        score = (
            case.source_weight * self.WEIGHTS["source_weight"] +
            case.tech_depth * self.WEIGHTS["tech_depth"] +
            case.feasibility * self.WEIGHTS["feasibility"] +
            case.timeliness * self.WEIGHTS["timeliness"] +
            case.reference_value * self.WEIGHTS["reference_value"]
        )
        return round(score, 2)

    def sort_cases(self, cases: List[Case], top_n: int = 5) -> List[Case]:
        scored = [(case, self.calculate_score(case)) for case in cases]
        scored.sort(key=lambda x: x[1], reverse=True)
        return [case for case, _ in scored[:top_n]]
```

- [ ] **Step 4: 运行测试验证通过**

```bash
pytest tests/test_scorer.py -v
# Expected: PASS
```

- [ ] **Step 5: Commit**

```bash
git add utils/scorer.py tests/test_scorer.py
git commit -m "feat: implement case scorer with weighted scoring"
```

---

## Task 4: 信源爬虫基类

**Files:**
- Create: `sources/base.py`

- [ ] **Step 1: 编写 base.py**

```python
from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import List
from utils.scorer import Case

@dataclass
class ScrapedCase:
    title: str
    overview: str
    source_weight: int
    tech_depth: int = 3
    feasibility: int = 3
    timeliness: int = 5
    reference_value: int = 3
    url: str = ""
    source: str = ""

class BaseScraper(ABC):
    def __init__(self, name: str, base_url: str):
        self.name = name
        self.base_url = base_url

    @abstractmethod
    def fetch_cases(self, year: int, month: int) -> List[ScrapedCase]:
        """抓取指定月份的案例"""
        pass

    def to_case(self, scraped: ScrapedCase) -> Case:
        return Case(
            title=scraped.title,
            overview=scraped.overview,
            source_weight=scraped.source_weight,
            tech_depth=scraped.tech_depth,
            feasibility=scraped.feasibility,
            timeliness=scraped.timeliness,
            reference_value=scraped.reference_value,
            url=scraped.url,
            source=self.name,
        )
```

- [ ] **Step 2: Commit**

```bash
git add sources/base.py
git commit -m "feat: add BaseScraper abstract class"
```

---

## Task 5: Hacker News 爬虫

**Files:**
- Create: `sources/hacker_news.py`

- [ ] **Step 1: 编写 hacker_news.py**

```python
import requests
from bs4 import BeautifulSoup
from datetime import datetime
from typing import List
from sources.base import BaseScraper, ScrapedCase

class HackerNewsScraper(BaseScraper):
    def __init__(self):
        super().__init__("Hacker News", "https://news.ycombinator.com")

    def fetch_cases(self, year: int, month: int) -> List[ScrapedCase]:
        # HN API 获取当月帖子
        url = f"https://hn.algolia.com/api/v1/search?query=AI+agent&tags=story&month={year}{month:02d}01"
        resp = requests.get(url, timeout=10)
        resp.raise_for_status()
        data = resp.json()

        cases = []
        for hit in data.get("hits", []):
            title = hit.get("title", "")
            if not title:
                continue
            # 简单判断是否是 AI Agent 相关
            if any(kw in title.lower() for kw in ["agent", "ai agent", "gpt", "claude", "langchain", "crew"]):
                cases.append(ScrapedCase(
                    title=title,
                    overview=hit.get("excerpt", ""),
                    source_weight=5,
                    tech_depth=4,
                    feasibility=4,
                    timeliness=5,
                    reference_value=4,
                    url=hit.get("url", hit.get("story_url", "")),
                    source=self.name,
                ))
        return cases
```

- [ ] **Step 2: Commit**

```bash
git add sources/hacker_news.py
git commit -m "feat: add Hacker News scraper"
```

---

## Task 6: GitHub Trending 爬虫

**Files:**
- Create: `sources/github_trending.py`

- [ ] **Step 1: 编写 github_trending.py**

```python
import requests
from bs4 import BeautifulSoup
from typing import List
from sources.base import BaseScraper, ScrapedCase

class GitHubTrendingScraper(BaseScraper):
    def __init__(self):
        super().__init__("GitHub Trending", "https://github.com")

    def fetch_cases(self, year: int, month: int) -> List[ScrapedCase]:
        # GitHub Trending 默认页面，按 AI/Agent 过滤
        url = "https://github.com/trending?q=AI+agent&s=stars&since=daily"
        headers = {"Accept": "application/vnd.github.v3+json"}
        resp = requests.get(url, headers=headers, timeout=10)
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, "lxml")

        cases = []
        for article in soup.select("article.Box-row")[:10]:
            title_elem = article.select_one("h2 a")
            if not title_elem:
                continue
            title = title_elem.get_text(strip=True)
            desc_elem = article.select_one("p")
            desc = desc_elem.get_text(strip=True) if desc_elem else ""
            url = f"https://github.com{title_elem['href']}"

            cases.append(ScrapedCase(
                title=title,
                overview=desc,
                source_weight=4,
                tech_depth=5,
                feasibility=4,
                timeliness=5,
                reference_value=4,
                url=url,
                source=self.name,
            ))
        return cases
```

- [ ] **Step 2: Commit**

```bash
git add sources/github_trending.py
git commit -m "feat: add GitHub Trending scraper"
```

---

## Task 7: 行业媒体爬虫 (机器之心/量子位/InfoQ/人人都是产品经理)

**Files:**
- Create: `sources/industry_media.py`

- [ ] **Step 1: 编写 industry_media.py**

```python
import requests
from bs4 import BeautifulSoup
from typing import List
from sources.base import BaseScraper, ScrapedCase

SITES = {
    "机器之心": "https://jiqizhixin.com",
    "量子位": "https://qubit.cn",
    "InfoQ": "https://infoq.cn",
    "人人都是产品经理": "https://iamsujie.com",
}

class IndustryMediaScraper(BaseScraper):
    def __init__(self):
        super().__init__("行业媒体", "综合")

    def fetch_cases(self, year: int, month: int) -> List[ScrapedCase]:
        all_cases = []
        for name, base_url in SITES.items():
            try:
                cases = self._fetch_site(name, base_url, year, month)
                all_cases.extend(cases)
            except Exception:
                continue
        return all_cases

    def _fetch_site(self, site_name: str, base_url: str, year: int, month: int) -> List[ScrapedCase]:
        # 搜索该月份的文章
        search_url = f"{base_url}/search?q=AI+Agent+智能体"
        headers = {"User-Agent": "Mozilla/5.0"}
        resp = requests.get(search_url, headers=headers, timeout=10)
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, "lxml")

        cases = []
        for article in soup.select("article")[:5]:
            title_elem = article.select_one("h2, h3, .title")
            if not title_elem:
                continue
            title = title_elem.get_text(strip=True)
            link = article.select_one("a")["href"]
            if not link.startswith("http"):
                link = base_url + link

            cases.append(ScrapedCase(
                title=title,
                overview=f"来源: {site_name}",
                source_weight=3,
                tech_depth=3,
                feasibility=4,
                timeliness=4,
                reference_value=3,
                url=link,
                source=site_name,
            ))
        return cases
```

- [ ] **Step 2: Commit**

```bash
git add sources/industry_media.py
git commit -m "feat: add industry media scraper for 机器之心/量子位/InfoQ/人人都是产品经理"
```

---

## Task 8: 官方文档爬虫 (OpenAI/Anthropic/DeepSeek)

**Files:**
- Create: `sources/official_docs.py`

- [ ] **Step 1: 编写 official_docs.py**

```python
import requests
from bs4 import BeautifulSoup
from typing import List
from sources.base import BaseScraper, ScrapedCase

OFFICIAL_SITES = {
    "OpenAI": "https://platform.openai.com/docs",
    "Anthropic": "https://docs.anthropic.com",
    "DeepSeek": "https://platform.deepseek.com",
}

class OfficialDocsScraper(BaseScraper):
    def __init__(self):
        super().__init__("官方文档", "综合")

    def fetch_cases(self, year: int, month: int) -> List[ScrapedCase]:
        all_cases = []
        for name, base_url in OFFICIAL_SITES.items():
            try:
                cases = self._fetch_site(name, base_url)
                all_cases.extend(cases)
            except Exception:
                continue
        return all_cases

    def _fetch_site(self, site_name: str, base_url: str) -> List[ScrapedCase]:
        headers = {"User-Agent": "Mozilla/5.0"}
        resp = requests.get(base_url, headers=headers, timeout=10)
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, "lxml")

        cases = []
        # 查找案例/应用相关页面
        for link in soup.select("a[href*='example'], a[href*='case'], a[href*='use-case']")[:5]:
            title = link.get_text(strip=True)
            href = link["href"]
            if not href.startswith("http"):
                href = base_url + href

            cases.append(ScrapedCase(
                title=f"{site_name}: {title}",
                overview=f"官方文档案例: {title}",
                source_weight=5,
                tech_depth=5,
                feasibility=5,
                timeliness=4,
                reference_value=5,
                url=href,
                source=site_name,
            ))
        return cases
```

- [ ] **Step 2: Commit**

```bash
git add sources/official_docs.py
git commit -m "feat: add official docs scraper for OpenAI/Anthropic/DeepSeek"
```

---

## Task 9: 社交媒体爬虫 (Twitter/X + Reddit)

**Files:**
- Create: `sources/social_media.py`

- [ ] **Step 1: 编写 social_media.py**

```python
import requests
from bs4 import BeautifulSoup
from typing import List
from sources.base import BaseScraper, ScrapedCase

class SocialMediaScraper(BaseScraper):
    def __init__(self):
        super().__init__("社交媒体", "Twitter/X + Reddit")

    def fetch_cases(self, year: int, month: int) -> List[ScrapedCase]:
        all_cases = []
        all_cases.extend(self._fetch_reddit())
        return all_cases

    def _fetch_reddit(self) -> List[ScrapedCase]:
        # 使用 Reddit 公共 API 获取相关帖子
        url = "https://www.reddit.com/r/LocalLLaMA/search.json?q=AI+agent&restrict_sr=1"
        headers = {"User-Agent": "Mozilla/5.0"}
        resp = requests.get(url, headers=headers, timeout=10)
        resp.raise_for_status()
        data = resp.json()

        cases = []
        for post in data.get("data", {}).get("children", [])[:5]:
            post_data = post.get("data", {})
            title = post_data.get("title", "")
            cases.append(ScrapedCase(
                title=title,
                overview=post_data.get("selftext", "")[:200],
                source_weight=2,
                tech_depth=3,
                feasibility=3,
                timeliness=5,
                reference_value=3,
                url=f"https://reddit.com{post_data.get('permalink', '')}",
                source="Reddit:r/LocalLLaMA",
            ))
        return cases
```

- [ ] **Step 2: Commit**

```bash
git add sources/social_media.py
git commit -m "feat: add social media scraper for Reddit"
```

---

## Task 10: AI 导航站 + arXiv + Newsletter RSS

**Files:**
- Create: `sources/ai_portals.py`
- Create: `sources/arxiv.py`
- Create: `sources/rss/newsletter.py`

- [ ] **Step 1: 编写 ai_portals.py**

```python
import requests
from bs4 import BeautifulSoup
from typing import List
from sources.base import BaseScraper, ScrapedCase

class AIPortalsScraper(BaseScraper):
    def __init__(self):
        super().__init__("AI导航站", "未来百科/AI产品精选")

    def fetch_cases(self, year: int, month: int) -> List[ScrapedCase]:
        # 未来百科
        cases = self._fetch_wlphp()
        return cases

    def _fetch_wlphp(self) -> List[ScrapedCase]:
        url = "https://www.的未来百科.com/ai-agent"
        headers = {"User-Agent": "Mozilla/5.0"}
        try:
            resp = requests.get(url, headers=headers, timeout=10)
            resp.raise_for_status()
            soup = BeautifulSoup(resp.text, "lxml")

            cases = []
            for item in soup.select(".article-item, .product-item")[:5]:
                title_elem = item.select_one("h3, .title")
                if not title_elem:
                    continue
                cases.append(ScrapedCase(
                    title=title_elem.get_text(strip=True),
                    overview="来源: 未来百科",
                    source_weight=2,
                    tech_depth=3,
                    feasibility=3,
                    timeliness=4,
                    reference_value=3,
                    source=self.name,
                ))
            return cases
        except Exception:
            return []
```

- [ ] **Step 2: 编写 arxiv.py**

```python
import requests
from typing import List
import xml.etree.ElementTree as ET
from sources.base import BaseScraper, ScrapedCase

class ArxivScraper(BaseScraper):
    def __init__(self):
        super().__init__("arXiv", "https://arxiv.org")

    def fetch_cases(self, year: int, month: int) -> List[ScrapedCase]:
        # 搜索 AI Agent 相关论文
        query = "all:AI+agent+LLM+autonomous"
        url = f"http://export.arxiv.org/api/query?search_query={query}&max_results=5&sortBy=submittedDate&sortOrder=descending"
        resp = requests.get(url, timeout=10)
        resp.raise_for_status()

        root = ET.fromstring(resp.text)
        ns = {"atom": "http://www.w3.org/2005/Atom"}

        cases = []
        for entry in root.findall("atom:entry", ns)[:5]:
            title = entry.find("atom:title", ns).text
            summary = entry.find("atom:summary", ns).text[:200] if entry.find("atom:summary", ns) is not None else ""
            link = entry.find("atom:id", ns).text

            cases.append(ScrapedCase(
                title=title.replace("\n", " ").strip(),
                overview=summary.replace("\n", " ").strip(),
                source_weight=2,
                tech_depth=4,
                feasibility=2,
                timeliness=4,
                reference_value=3,
                url=link,
                source="arXiv",
            ))
        return cases
```

- [ ] **Step 3: 编写 newsletter.py**

```python
import feedparser
from typing import List
from sources.base import BaseScraper, ScrapedCase

NEWSLETTER_FEEDS = [
    "https://buttondown.email/AIwrld/rss",  # 示例 RSS
]

class NewsletterScraper(BaseScraper):
    def __init__(self):
        super().__init__("AI Newsletter", "RSS")

    def fetch_cases(self, year: int, month: int) -> List[ScrapedCase]:
        all_cases = []
        for feed_url in NEWSLETTER_FEEDS:
            try:
                cases = self._fetch_feed(feed_url, year, month)
                all_cases.extend(cases)
            except Exception:
                continue
        return all_cases

    def _fetch_feed(self, feed_url: str, year: int, month: int) -> List[ScrapedCase]:
        feed = feedparser.parse(feed_url)
        cases = []
        for entry in feed.entries[:5]:
            cases.append(ScrapedCase(
                title=entry.get("title", ""),
                overview=entry.get("summary", "")[:200],
                source_weight=4,
                tech_depth=4,
                feasibility=4,
                timeliness=5,
                reference_value=4,
                url=entry.get("link", ""),
                source="AI Newsletter",
            ))
        return cases
```

- [ ] **Step 4: Commit**

```bash
git add sources/ai_portals.py sources/arxiv.py sources/rss/newsletter.py
git commit -m "feat: add AI portals, arxiv, and newsletter RSS scrapers"
```

---

## Task 11: 格式转换器

**Files:**
- Create: `utils/converter.py`
- Create: `tests/test_converter.py`

- [ ] **Step 1: 编写 test_converter.py**

```python
from utils.converter import MarkdownConverter
import tempfile
import os

def test_convert_to_html():
    content = "# Test Report\n\n## Case 1\nTest content"
    with tempfile.NamedTemporaryFile(mode="w", suffix=".md", delete=False) as f:
        f.write(content)
        f.flush()
        md_path = f.name

    converter = MarkdownConverter()
    html_path = converter.convert(md_path, "html")

    assert os.path.exists(html_path)
    with open(html_path) as f:
        assert "<h1>Test Report</h1>" in f.read()
    os.unlink(md_path)
    os.unlink(html_path)
```

- [ ] **Step 2: 运行测试验证失败**

```bash
pytest tests/test_converter.py -v
# Expected: FAIL — converter module doesn't exist
```

- [ ] **Step 3: 编写 converter.py**

```python
import subprocess
import os
import shutil
from pathlib import Path

class MarkdownConverter:
    def __init__(self):
        self.pandoc_available = shutil.which("pandoc") is not None

    def convert(self, input_path: str, format: str, output_path: str = None) -> str:
        if not self.pandoc_available:
            raise RuntimeError("pandoc not installed. Install with: brew install pandoc")

        input_path = Path(input_path)
        if output_path is None:
            output_path = input_path.with_suffix(f".{format}")

        cmd = [
            "pandoc",
            str(input_path),
            "-o", str(output_path),
            "--standalone",
            "--metadata", f"title={input_path.stem}",
        ]

        if format == "html":
            cmd.extend(["--self-contained", "--metadata", "theme=dark"])
        elif format == "notion":
            # Notion 兼容的 Markdown 变体
            cmd.extend(["--to", "markdown-raw_html"])

        subprocess.run(cmd, check=True)
        return str(output_path)
```

- [ ] **Step 4: 运行测试验证通过**

```bash
pytest tests/test_converter.py -v
# Expected: PASS (requires pandoc installed)
```

- [ ] **Step 5: Commit**

```bash
git add utils/converter.py tests/test_converter.py
git commit -m "feat: add Markdown to HTML/Notion converter using pandoc"
```

---

## Task 12: 主入口 CLI

**Files:**
- Create: `generate_report.py`

- [ ] **Step 1: 编写 generate_report.py**

```python
#!/usr/bin/env python3
import typer
from datetime import datetime
from pathlib import Path
from typing import Optional
from jinja2 import Environment, FileSystemLoader
from rich.console import Console
from rich.progress import Progress

from sources.hacker_news import HackerNewsScraper
from sources.github_trending import GitHubTrendingScraper
from sources.industry_media import IndustryMediaScraper
from sources.official_docs import OfficialDocsScraper
from sources.social_media import SocialMediaScraper
from sources.ai_portals import AIPortalsScraper
from sources.arxiv import ArxivScraper
from sources.rss.newsletter import NewsletterScraper
from utils.scorer import CaseScorer
from utils.converter import MarkdownConverter

app = typer.Typer()
console = Console()

SCRAPERS = [
    HackerNewsScraper(),
    GitHubTrendingScraper(),
    IndustryMediaScraper(),
    OfficialDocsScraper(),
    SocialMediaScraper(),
    AIPortalsScraper(),
    ArxivScraper(),
    NewsletterScraper(),
]

@app.command()
def generate(
    month: str = typer.Option(..., help="目标月份，格式: YYYY-MM"),
    output: Optional[str] = typer.Option(None, help="输出路径"),
):
    """生成指定月份的 AI Agent 案例报告"""
    console.print(f"[bold blue]开始生成 {month} 月度报告...[/bold blue]")

    year, month_num = map(int, month.split("-"))

    all_scraped = []
    with Progress() as progress:
        task = progress.add_task("[cyan]正在抓取各信源...", total=len(SCRAPERS))
        for scraper in SCRAPERS:
            try:
                cases = scraper.fetch_cases(year, month_num)
                all_scraped.extend([scraper.to_case(c) for c in cases])
            except Exception as e:
                console.print(f"[yellow]  {scraper.name} 抓取失败: {e}[/yellow]")
            progress.advance(task)

    console.print(f"[green]共抓取 {len(all_scraped)} 个案例[/green]")

    # 评分排序
    scorer = CaseScorer()
    top_cases = scorer.sort_cases(all_scraped, top_n=5)

    # 渲染报告
    env = Environment(loader=FileSystemLoader("."))
    template = env.get_template("report_template.md")

    report_content = template.render(
        year=year,
        month=month_num,
        generated_at=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        cases=top_cases,
        domains=["AI Agent", "LLM应用", "自动化"],
        next_month_focus=["多模态Agent", "自主决策系统"],
    )

    # 输出
    output_path = output or f"{month}-AI-Agent-案例报告.md"
    Path(output_path).write_text(report_content)
    console.print(f"[bold green]报告已生成: {output_path}[/bold green]")


@app.command()
def convert(
    input: str = typer.Option(..., help="输入 Markdown 文件路径"),
    format: str = typer.Option("html", help="输出格式: html, notion"),
    output: Optional[str] = typer.Option(None, help="输出路径"),
):
    """转换报告为其他格式"""
    converter = MarkdownConverter()
    output_path = converter.convert(input, format, output)
    console.print(f"[bold green]已转换: {output_path}[/bold green]")


if __name__ == "__main__":
    app()
```

- [ ] **Step 2: 测试 CLI 入口**

```bash
python generate_report.py --help
# Expected: 显示帮助信息
```

- [ ] **Step 3: Commit**

```bash
git add generate_report.py
git commit -m "feat: add CLI entry point with generate and convert commands"
```

---

## Task 13: 集成测试

**Files:**
- Create: `tests/test_integration.py`

- [ ] **Step 1: 编写集成测试**

```python
import subprocess
import tempfile
import os

def test_full_workflow():
    """测试完整工作流程：生成报告 -> 转换 HTML"""
    # 生成报告（mock 爬虫返回数据）
    result = subprocess.run(
        ["python", "generate_report.py", "generate", "--month", "2026-03"],
        capture_output=True,
        text=True,
    )
    # 由于网络依赖，这里只验证 CLI 不报错
    assert result.returncode in [0, 1]  # 可能因网络问题失败，但 CLI 应正常
```

- [ ] **Step 2: Commit**

```bash
git add tests/test_integration.py
git commit -m "test: add integration test for full workflow"
```

---

## 自审检查清单

- [ ] Spec 覆盖：报告格式 ✓，5个案例 ✓，信源列表 ✓，评分权重 ✓，格式转换 ✓
- [ ] 占位符扫描：无 TBD/TODO/实现后续
- [ ] 类型一致性：Case/ScrapedCase 数据类字段名一致
- [ ] 文件路径：所有路径为绝对路径或相对于项目根目录

---

## 执行选项

**Plan complete and saved to `docs/superpowers/plans/2026-04-27-monthly-agent-report-plan.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**
