#!/bin/bash
# check_source_sufficiency.sh
# 检查每个数据源是否达到最低目标，确保搜索充分

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
    ["机器之心"]=15
    ["量子位"]=15
)

# 从 index.json 统计各数据源数量
TOTAL=$(grep -o '"total_count":[0-9]*' "$INDEX_FILE" | grep -o '[0-9]*')

echo "=== 数据源充足性检查 ==="
echo "当前总数: $TOTAL / 目标: 100"
echo ""

all_sufficient=true
insufficient_sources=""

for source in "${!SOURCE_TARGETS[@]}"; do
    target=${SOURCE_TARGETS[$source]}
    # 统计该数据源的条目数（通过计算该 source 出现的次数）
    count=$(grep -o "\"source\": *\"[^\"]*${source}[^\"]*\"" "$INDEX_FILE" 2>/dev/null | wc -l | tr -d ' ')
    if [ -z "$count" ]; then count=0; fi

    if [ "$count" -ge "$target" ]; then
        status="✅ 充足"
    else
        status="❌ 不足 (需要 $target)"
        all_sufficient=false
        insufficient_sources="$insufficient_sources  - $source: $count / $target\n"
    fi

    echo "$source: $count (目标: $target) $status"
done

echo ""

if [ "$TOTAL" -lt 100 ]; then
    echo "❌ 总数不足: $TOTAL / 100"
    all_sufficient=false
fi

echo ""

if [ "$all_sufficient" = true ]; then
    echo "✅ 所有数据源已充足，可以进入下一阶段"
    exit 0
else
    echo "❌ 仍有数据源不足，需要继续搜索:"
    echo -e "$insufficient_sources"
    exit 1
fi
