#!/usr/bin/env python3
"""
从微信公众号相册页面HTML中提取文章列表

用法:
    python extract_articles.py <html_file> [output_file]

示例:
    python extract_articles.py /tmp/wechat_html.txt
    python extract_articles.py /tmp/wechat_html.txt articles.json
"""

import re
import json
import sys
from datetime import datetime, timedelta
from pathlib import Path

def log(msg):
    print(msg, file=sys.stderr)

# 当前日期（从系统获取）
CURRENT_DATE = datetime.now()

def parse_date(date_str):
    """将相对日期或绝对日期转换为 YYYY-MM-DD 格式"""
    date_str = date_str.strip()

    if date_str == '昨天':
        return (CURRENT_DATE - timedelta(days=1)).strftime('%Y-%m-%d')
    elif date_str == '前天':
        return (CURRENT_DATE - timedelta(days=2)).strftime('%Y-%m-%d')
    elif '天前' in date_str:
        match = re.search(r'(\d+)', date_str)
        if match:
            days = int(match.group(1))
            return (CURRENT_DATE - timedelta(days=days)).strftime('%Y-%m-%d')
    elif '周前' in date_str:
        match = re.search(r'(\d+)', date_str)
        if match:
            weeks = int(match.group(1))
            return (CURRENT_DATE - timedelta(days=weeks * 7)).strftime('%Y-%m-%d')
    elif '年' in date_str:
        # 格式: "2025年05月29日" 或 "2026年04月08日"
        match = re.match(r'(\d{4})年(\d{2})月(\d{2})日', date_str)
        if match:
            return f"{match.group(1)}-{match.group(2)}-{match.group(3)}"
    elif re.match(r'\d{2}/\d{2}', date_str):
        # 格式: "04/08" -> 2026-04-08
        parts = date_str.split('/')
        return f"{CURRENT_DATE.year}-{parts[0]}-{parts[1]}"

    return date_str


def extract_articles(html_content):
    """
    从HTML中提取文章列表

    HTML中每个文章项是 <li class="album__list-item"> 标签，包含:
    - data-link: 文章URL
    - data-title: 文章标题
    - data-msgid: mid
    - data-itemidx: idx
    - <span class="js_article_create_time">: 发布日期
    """
    # 正则匹配文章项
    item_pattern = re.compile(
        r'<li[^>]*class="album__list-item[^"]*"[^>]*data-msgid="(\d+)"[^>]*data-itemidx="(\d+)"[^>]*data-link="([^"]+)"[^>]*data-title="([^"]+)"[^>]*>.*?<span[^>]*class="js_article_create_time[^"]*">([^<]+)</span>',
        re.DOTALL
    )

    articles = []
    seen_titles = set()

    for match in item_pattern.finditer(html_content):
        msgid = match.group(1)
        itemidx = match.group(2)
        link = match.group(3).replace('&amp;', '&')
        title = match.group(4)
        date_str = match.group(5).strip()

        # 清理标题中的HTML实体
        title = title.replace('&amp;', '&').replace('&quot;', '"').replace('&#39;', "'")

        # 去重
        if title in seen_titles:
            continue
        seen_titles.add(title)

        articles.append({
            'mid': int(msgid),
            'idx': int(itemidx),
            'url': link,
            'title': title,
            'date_str': date_str,
            'date': parse_date(date_str)
        })

    # 按mid降序排列（最新的在前）
    articles.sort(key=lambda x: (-x['mid'], -x['idx']))

    return articles


def filter_by_month(articles, year, month):
    """筛选指定月份的文章"""
    month_str = f"{year}-{month:02d}"
    return [a for a in articles if a['date'].startswith(month_str)]


def generate_markdown(articles, account_name, year, month):
    """生成Markdown格式内容"""
    month_str = f"{year}年{month}月"

    md = f"# {account_name} {month_str}文章列表\n\n"
    md += f"共 {len(articles)} 篇文章\n\n---\n\n"

    for i, art in enumerate(articles, 1):
        md += f"## {i}. [{art['title']}]({art['url']})\n"
        md += f"**日期**: {art['date']}\n\n"

    return md


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    html_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None

    # 读取HTML文件
    html_path = Path(html_file)
    if not html_path.exists():
        print(f"错误: 文件不存在 {html_file}")
        sys.exit(1)

    html_content = html_path.read_text(encoding='utf-8')

    # 提取文章
    articles = extract_articles(html_content)
    log(f"共提取 {len(articles)} 篇文章")

    # 如果指定了年月，筛选该月份
    if len(sys.argv) >= 4:
        year = int(sys.argv[3])
        month = int(sys.argv[4])
        articles = filter_by_month(articles, year, month)
        log(f"筛选 {year}年{month}月: {len(articles)} 篇文章")

    # 输出结果
    if output_file:
        # JSON格式输出
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(articles, f, ensure_ascii=False, indent=2)
        log(f"已保存到: {output_file}")
    else:
        # 默认输出到stdout
        for i, art in enumerate(articles, 1):
            print(f"{i}. {art['title']}")
            print(f"   日期: {art['date']}")
            print(f"   URL: {art['url']}")
            print()


if __name__ == '__main__':
    main()
