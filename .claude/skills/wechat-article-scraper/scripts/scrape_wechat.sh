#!/bin/bash
# scrape_wechat.sh - 从微信公众号相册页面抓取文章
#
# 用法:
#   ./scrape_wechat.sh <url> <output_folder> <year-month> <account_name>
#
# 示例:
#   ./scrape_wechat.sh "https://mp.weixin.qq.com/mp/appmsgalbum?__biz=..." "jiqi" "2026-04" "AI应用观察"
#
# 输出文件: <output_folder>/<account_name>_2026_04.md
#
# 依赖:
#   - gstack browse (~/.claude/skills/gstack/browse/dist/browse)
#   - extract_articles.py (同目录下的Python脚本)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BROWSE="$HOME/.claude/skills/gstack/browse/dist/browse"
HTML_FILE="/tmp/wechat_html.txt"

# 解析参数
if [ $# -lt 4 ]; then
    echo "用法: $0 <url> <output_folder> <year-month> <account_name>"
    echo ""
    echo "参数:"
    echo "  url           微信公众号相册页面URL"
    echo "  output_folder 输出文件夹路径"
    echo "  year-month    年月，格式 YYYY-MM"
    echo "  account_name  公众号名称（用于生成文件名和标题）"
    exit 1
fi

URL="$1"
OUTPUT_FOLDER="$2"
YEAR_MONTH="$3"
ACCOUNT_NAME="$4"

# 解析年月
YEAR=$(echo "$YEAR_MONTH" | cut -d'-' -f1)
MONTH=$(echo "$YEAR_MONTH" | cut -d'-' -f2)

# 生成输出文件名: account_yyyy_mm.md
OUTPUT_FILE="${OUTPUT_FOLDER}/${ACCOUNT_NAME}_${YEAR}_$(printf '%02d' $MONTH).md"

# 抓取时间
SCRAPE_DATE=$(date +%Y-%m-%d)

echo "开始抓取..."
echo "  URL: $URL"
echo "  账号: $ACCOUNT_NAME"
echo "  输出文件: $OUTPUT_FILE"

# 创建输出目录
mkdir -p "$OUTPUT_FOLDER"

# 访问页面
echo "正在访问页面..."
$BROWSE goto "$URL"
$BROWSE wait --load

# 滚动加载所有文章
echo "正在滚动加载文章..."
for i in {1..15}; do
    $BROWSE scroll
    sleep 0.5
done
$BROWSE wait --networkidle

# 保存HTML
echo "正在保存页面..."
$BROWSE html > "$HTML_FILE"

# 计算当前日期（用于日期转换）
CURRENT_YEAR=$(date +%Y)
CURRENT_MONTH=$(date +%m)
CURRENT_DAY=$(date +%d)

# 使用Python脚本提取文章
echo "正在提取文章..."
if [ -n "$ACCOUNT_NAME" ]; then
    # 如果提供了账号名，生成Markdown
    python3 "$SCRIPT_DIR/extract_articles.py" "$HTML_FILE" /dev/stdout "$YEAR" "$MONTH" | \
        python3 -c "
import sys
import json
import re

articles = json.load(sys.stdin)

# 解析年月
year_month = '$YEAR_MONTH'
year = year_month.split('-')[0]
month = year_month.split('-')[1]
account = '$ACCOUNT_NAME'
scrape_date = '$SCRAPE_DATE'

# 计算日期范围
dates = [art['date'] for art in articles]
date_range = f'{min(dates)} ~ {max(dates)}' if dates else '无文章'

md = f'# {account} {year}年{month}月文章列表\n\n'
md += f'- **抓取时间**: {scrape_date}\n'
md += f'- **日期范围**: {date_range}\n'
md += f'- **文章数量**: {len(articles)} 篇\n\n'
md += f'- **专辑URL**: $URL\n\n'
md += '---\n\n'

for i, art in enumerate(articles, 1):
    md += f'## {i}. [{art[\"title\"]}]({art[\"url\"]})\n'
    md += f'**日期**: {art[\"date\"]}\n\n'

print(md)
" > "$OUTPUT_FILE"
else
    # 否则输出JSON
    python3 "$SCRIPT_DIR/extract_articles.py" "$HTML_FILE" "$OUTPUT_FOLDER/articles.json" "$YEAR" "$MONTH"
fi

echo ""
echo "完成！"
echo "输出文件: $OUTPUT_FILE"

ls -la "$OUTPUT_FILE"