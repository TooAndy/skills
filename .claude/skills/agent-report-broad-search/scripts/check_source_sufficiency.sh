#!/bin/bash
# check_source_sufficiency.sh
# 检查每个数据源是否达到最低目标，确保搜索充分
# 区分"没搜够"和"真的没内容"两种情况

REPORTS_DIR="$1"
YEAR_MONTH="$2"

if [ -z "$REPORTS_DIR" ] || [ -z "$YEAR_MONTH" ]; then
    echo "Usage: check_source_sufficiency.sh <reports_dir> <year-month>"
    exit 1
fi

INDEX_FILE="$REPORTS_DIR/$YEAR_MONTH/index.json"

if [ ! -f "$INDEX_FILE" ]; then
    echo "ERROR: index.json not found at $INDEX_FILE"
    exit 1
fi

# 数据源最低目标
declare -A SOURCE_TARGETS=(
    ["Hacker News"]=30
    ["GitHub Trending"]=20
    ["GitHub Search"]=30
    ["Reddit"]=10
    ["Product Hunt"]=10
    ["机器之心"]=20
    ["量子位"]=20
)

# 从 index.json 统计各数据源数量
TOTAL=$(grep -o '"total_count":[0-9]*' "$INDEX_FILE" | grep -o '[0-9]*')

echo "=== 数据源充足性检查 ==="
echo "当前总数: $TOTAL / 目标: 100"
echo ""

# 检查各数据源
all_sufficient=true
insufficient_sources=""
insufficient_details=""

for source in "${!SOURCE_TARGETS[@]}"; do
    target=${SOURCE_TARGETS[$source]}
    # 统计该数据源的条目数
    count=$(grep -o "\"source\": *\"[^\"]*${source}[^\"]*\"" "$INDEX_FILE" 2>/dev/null | wc -l | tr -d ' ')
    if [ -z "$count" ]; then count=0; fi

    if [ "$count" -ge "$target" ]; then
        status="✅ 充足"
    else
        # 低于目标需要进一步判断
        # 如果 count > 0 但 < target，说明该信源有内容但数量有限
        # 如果 count = 0，说明该信源可能根本没有内容
        if [ "$count" -eq 0 ]; then
            status="❌ 未搜索 (0 / $target)"
            all_sufficient=false
            insufficient_details="${insufficient_details}  - $source: 未搜索\n"
        else
            status="⚠️  数量有限 ($count / $target)"
            # 数量有限但不是零，需要判断是否已充分搜索
            # 对于中文信源，如果确实没有更多内容，可以接受
            if [[ "$source" == "机器之心" || "$source" == "量子位" ]]; then
                insufficient_details="${insufficient_details}  - $source: ⚠️ 数量有限，但可能当月内容确实较少，请确认是否已爬取所有文章\n"
            else
                all_sufficient=false
                insufficient_details="${insufficient_details}  - $source: 数量不足 ($count / $target)\n"
            fi
        fi
        insufficient_sources="$insufficient_sources  - $source: $count / $target\n"
    fi

    echo "$source: $count (目标: $target) $status"
done

echo ""

if [ "$TOTAL" -lt 100 ]; then
    echo "❌ 总数不足: $TOTAL / 100"
    if [ "$all_sufficient" = true ]; then
        echo "⚠️  注意: 所有数据源已达到最低目标，但总数未达 100"
        echo "   建议继续搜索更多来源以提高报告质量"
    fi
    all_sufficient=false
else
    if [ "$all_sufficient" = true ]; then
        echo "✅ 所有数据源已充足，总数达标，可以进入下一阶段"
    fi
fi

echo ""

if [ "$all_sufficient" = true ]; then
    echo "✅ 所有数据源已充足，可以进入下一阶段"
    exit 0
else
    echo "❌ 仍有数据源需要处理:"
    echo -e "$insufficient_sources"
    if [ -n "$insufficient_details" ]; then
        echo ""
        echo "详情:"
        echo -e "$insufficient_details"
    fi
    echo ""
    echo "建议:"
    echo "  - 对于未搜索的信源，请继续搜索"
    echo "  - 对于数量有限的信源（如量子位），请确认是否已爬取所有可用文章"
    echo "  - 如果确认信源内容确实较少，可记录原因后继续"
    exit 1
fi
