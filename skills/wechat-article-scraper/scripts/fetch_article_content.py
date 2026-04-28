#!/usr/bin/env python3
"""
抓取微信文章的完整内容

用法:
    python fetch_article_content.py <articles_json> <output_folder> <account_name> <browse_path>

示例:
    python fetch_article_content.py "reports/2026-04/wechat_articles/index.json" "reports/2026-04/wechat_articles" "机器之心" "~/.claude/skills/gstack/browse/dist/browse"
"""

import json
import subprocess
import sys
from pathlib import Path


def fetch_article(browse_path, url, output_file, title, date, account_name):
    """抓取单篇文章的完整内容"""
    print(f"  抓取: {title[:50]}...")

    try:
        # 访问文章页面
        subprocess.run([browse_path, 'goto', url], check=True, capture_output=True)
        subprocess.run([browse_path, 'wait', '--load'], check=True, capture_output=True)
        subprocess.run([browse_path, 'wait', '--networkidle'], check=True, capture_output=True)

        # 获取完整页面文本（不用任何摘要功能）
        result = subprocess.run([browse_path, 'text'], capture_output=True, text=True, check=True)
        content = result.stdout

        # 写入文件
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(f"# {title}\n")
            f.write(f"**来源**: {account_name}\n")
            f.write(f"**日期**: {date}\n")
            f.write(f"**链接**: {url}\n")
            f.write("\n---\n\n")
            f.write(content)

        return True
    except subprocess.CalledProcessError as e:
        print(f"    失败: {e}")
        return False


def main():
    if len(sys.argv) < 5:
        print(__doc__)
        sys.exit(1)

    articles_json = sys.argv[1]
    output_folder = sys.argv[2]
    account_name = sys.argv[3]
    browse_path = sys.argv[4]

    # 读取文章列表
    with open(articles_json, 'r', encoding='utf-8') as f:
        articles = json.load(f)

    print(f"开始抓取 {len(articles)} 篇文章...")

    success_count = 0
    for i, art in enumerate(articles, 1):
        article_id = art['mid']
        article_url = art['url']
        article_title = art['title']
        article_date = art['date']
        output_file = str(Path(output_folder) / f"{article_id}.md")

        print(f"[{i}/{len(articles)}] ", end="", flush=True)
        if fetch_article(browse_path, article_url, output_file, article_title, article_date, account_name):
            success_count += 1

    print(f"\n完成！成功 {success_count}/{len(articles)} 篇")


if __name__ == '__main__':
    main()