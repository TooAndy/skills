#!/bin/bash
# scrape_wechat.sh - 从微信公众号相册页面抓取文章列表和内容
#
# 用法:
#   ./scrape_wechat.sh <url> <output_folder> <year-month> <account_name>
#
# 示例:
#   ./scrape_wechat.sh "https://mp.weixin.qq.com/mp/appmsgalbum?__biz=..." "reports/2026-04/wechat_articles/机器之心_AI开源项目" "2026-04" "机器之心_AI开源项目"
#
# 输出文件:
#   <output_folder>/index.json           # 文章列表索引
#   <output_folder>/<文章id>.md         # 各篇文章完整内容

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

# 抓取时间
SCRAPE_DATE=$(date +%Y-%m-%d)

echo "开始抓取..."
echo "  URL: $URL"
echo "  账号: $ACCOUNT_NAME"
echo "  输出目录: $OUTPUT_FOLDER"

# 创建输出目录
mkdir -p "$OUTPUT_FOLDER"

# 访问页面
echo "正在访问页面..."
"$BROWSE" goto "$URL"
"$BROWSE" wait --load

# 滚动加载所有文章
echo "正在滚动加载文章..."
for i in {1..15}; do
    "$BROWSE" scroll
    sleep 0.5
done
"$BROWSE" wait --networkidle

# 保存HTML
echo "正在保存页面..."
"$BROWSE" html > "$HTML_FILE"

# 使用Python脚本提取文章列表
echo "正在提取文章列表..."
ARTICLES_JSON="$OUTPUT_FOLDER/index.json"
python3 "$SCRIPT_DIR/extract_articles.py" "$HTML_FILE" "$ARTICLES_JSON" "$YEAR" "$MONTH"

# 读取文章列表并抓取内容
ARTICLE_COUNT=$(python3 -c "import json; print(len(json.load(open('$ARTICLES_JSON'))))")
echo "共 $ARTICLE_COUNT 篇文章，开始抓取内容..."

# 逐个抓取文章内容
python3 "$SCRIPT_DIR/fetch_article_content.py" "$ARTICLES_JSON" "$OUTPUT_FOLDER" "$ACCOUNT_NAME" "$BROWSE"

echo ""
echo "完成！"
echo "输出目录: $OUTPUT_FOLDER"
ls -la "$OUTPUT_FOLDER"