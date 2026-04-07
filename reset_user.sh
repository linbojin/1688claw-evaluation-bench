#!/bin/bash
# 重置单个用户的数据（不影响其他用户）
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <user_id>  (e.g. user_006)"
  exit 1
fi

USER_ID="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_PATH="$SCRIPT_DIR/db/benchmark.db"
SEED_FILE="$SCRIPT_DIR/db/seed/users/${USER_ID}.sql"

if [ ! -f "$SEED_FILE" ]; then
  echo "❌ Seed file not found: $SEED_FILE"
  exit 1
fi

echo "🔄 重置用户 $USER_ID ..."

# 删除该用户的所有数据（逆序删除避免外键冲突）
sqlite3 "$DB_PATH" <<SQL
PRAGMA foreign_keys = OFF;
DELETE FROM eval_runs WHERE user_id = '$USER_ID';
DELETE FROM orders WHERE shop_code IN (SELECT shop_code FROM shops WHERE user_id = '$USER_ID');
DELETE FROM listings WHERE shop_code IN (SELECT shop_code FROM shops WHERE user_id = '$USER_ID');
DELETE FROM search_snapshots WHERE user_id = '$USER_ID';
DELETE FROM shops WHERE user_id = '$USER_ID';
DELETE FROM users WHERE user_id = '$USER_ID';
PRAGMA foreign_keys = ON;
SQL

# 重新导入 seed
sqlite3 "$DB_PATH" < "$SEED_FILE"

echo "✅ 用户 $USER_ID 重置完成"
echo "   上架商品: $(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM listings l JOIN shops s ON l.shop_code=s.shop_code WHERE s.user_id='$USER_ID';")"
echo "   出单记录: $(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM orders o JOIN shops s ON o.shop_code=s.shop_code WHERE s.user_id='$USER_ID';")"
