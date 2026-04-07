#!/bin/bash
# 全量重置benchmark数据库
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_PATH="$SCRIPT_DIR/db/benchmark.db"
SEED_DIR="$SCRIPT_DIR/db/seed"

echo "🔄 重置 benchmark 数据库..."

# 删除旧数据库
rm -f "$DB_PATH"

# 重建 schema
sqlite3 "$DB_PATH" < "$SEED_DIR/schema.sql"
echo "✅ Schema 建立完成"

# 导入商品池
sqlite3 "$DB_PATH" < "$SEED_DIR/products_pool.sql"
echo "✅ 商品池导入完成 ($(sqlite3 "$DB_PATH" 'SELECT COUNT(*) FROM products_pool;') 条)"

# 导入所有用户
for f in "$SEED_DIR/users"/user_*.sql; do
  user_id=$(basename "$f" .sql)
  sqlite3 "$DB_PATH" < "$f"
  echo "  ✅ $user_id 导入完成"
done

echo ""
echo "✅ 数据库重置完成: $DB_PATH"
echo "   用户数: $(sqlite3 "$DB_PATH" 'SELECT COUNT(*) FROM users;')"
echo "   店铺数: $(sqlite3 "$DB_PATH" 'SELECT COUNT(*) FROM shops;')"
echo "   上架记录: $(sqlite3 "$DB_PATH" 'SELECT COUNT(*) FROM listings;')"
echo "   出单记录: $(sqlite3 "$DB_PATH" 'SELECT COUNT(*) FROM orders;')"
