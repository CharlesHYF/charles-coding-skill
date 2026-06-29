#!/bin/bash
set -e

MIGRATIONS_DIR="db/init"
HISTORY_FILE="$MIGRATIONS_DIR/.migration_history"

# 读取数据库连接信息（从 .env 或 docker-compose 推断）
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-postgres}"
DB_PASS="${DB_PASSWORD:-postgres}"
DB_NAME="${DB_NAME:-mydb}"

# 简单判断数据库类型（按端口）
if [ "$DB_PORT" = "5432" ]; then
  DB_TYPE="postgresql"
  CMD="psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f"
elif [ "$DB_PORT" = "3306" ]; then
  DB_TYPE="mysql"
  CMD="mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $DB_NAME -e"
else
  echo "❌ 不支持的数据库端口: $DB_PORT"
  exit 1
fi

# 创建历史记录文件
touch "$HISTORY_FILE"

echo "🔄 开始执行数据库迁移..."

for file in $(ls "$MIGRATIONS_DIR"/*.sql 2>/dev/null | sort); do
  filename=$(basename "$file")
  if grep -Fxq "$filename" "$HISTORY_FILE"; then
    echo "⏭️  跳过已执行: $filename"
  else
    echo "▶️  执行: $filename"
    if [ "$DB_TYPE" = "postgresql" ]; then
      PGPASSWORD="$DB_PASS" $CMD "$file"
    else
      $CMD "source $file"
    fi
    echo "$filename" >> "$HISTORY_FILE"
  fi
done

echo "✅ 数据库迁移完成！"