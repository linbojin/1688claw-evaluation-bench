-- 1688-shopkeeper Benchmark Database Schema

PRAGMA foreign_keys = ON;

-- 用户表
CREATE TABLE IF NOT EXISTS users (
  user_id       TEXT PRIMARY KEY,
  ak            TEXT,
  ak_status     TEXT NOT NULL DEFAULT 'missing',  -- configured / missing / expiring / expired
  persona       TEXT,
  created_at    TEXT NOT NULL DEFAULT (datetime('now'))
);

-- 店铺表
CREATE TABLE IF NOT EXISTS shops (
  shop_code       TEXT PRIMARY KEY,
  user_id         TEXT NOT NULL,
  name            TEXT NOT NULL,
  channel         TEXT NOT NULL,  -- douyin / pinduoduo / xiaohongshu / taobao
  is_authorized   INTEGER NOT NULL DEFAULT 1,  -- 1=valid, 0=expired
  auth_expires_at TEXT,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 1688商品池（mock用，代表1688上可搜索到的商品）
CREATE TABLE IF NOT EXISTS products_pool (
  item_id           TEXT PRIMARY KEY,
  title             TEXT NOT NULL,
  price             REAL NOT NULL,
  category          TEXT NOT NULL,
  last30DaysSales   INTEGER NOT NULL DEFAULT 0,
  goodRates         REAL NOT NULL DEFAULT 0.9,
  repurchaseRate    REAL NOT NULL DEFAULT 0.05,
  downstreamOffer   INTEGER NOT NULL DEFAULT 100,
  remarkCnt         INTEGER NOT NULL DEFAULT 50,
  collectionRate24h REAL NOT NULL DEFAULT 0.85,
  totalSales        INTEGER NOT NULL DEFAULT 0,
  earliestListingTime TEXT,
  image_url         TEXT,
  merchant_name     TEXT,
  merchant_type     TEXT DEFAULT 'factory'  -- factory / trader
);

-- 搜索快照（search命令生成）
CREATE TABLE IF NOT EXISTS search_snapshots (
  data_id     TEXT PRIMARY KEY,  -- YYYYMMDD_HHMMSS_mmm
  user_id     TEXT NOT NULL,
  query       TEXT NOT NULL,
  channel     TEXT,
  created_at  TEXT NOT NULL DEFAULT (datetime('now')),
  product_ids TEXT NOT NULL,  -- JSON array of item_ids
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 上架记录（publish命令写入）
CREATE TABLE IF NOT EXISTS listings (
  listing_id  TEXT PRIMARY KEY,
  shop_code   TEXT NOT NULL,
  item_id     TEXT NOT NULL,
  listed_at   TEXT NOT NULL DEFAULT (datetime('now')),
  status      TEXT NOT NULL DEFAULT 'active',  -- active / removed
  FOREIGN KEY (shop_code) REFERENCES shops(shop_code),
  FOREIGN KEY (item_id) REFERENCES products_pool(item_id),
  UNIQUE(shop_code, item_id)
);

-- 出单记录（用于shop_daily读取）
CREATE TABLE IF NOT EXISTS orders (
  order_id    TEXT PRIMARY KEY,
  shop_code   TEXT NOT NULL,
  item_id     TEXT NOT NULL,
  order_date  TEXT NOT NULL,
  quantity    INTEGER NOT NULL DEFAULT 1,
  revenue     REAL NOT NULL DEFAULT 0,
  FOREIGN KEY (shop_code) REFERENCES shops(shop_code)
);

-- 评测运行记录
CREATE TABLE IF NOT EXISTS eval_runs (
  run_id      TEXT PRIMARY KEY,
  task_id     TEXT NOT NULL,
  user_id     TEXT NOT NULL,
  run_at      TEXT NOT NULL DEFAULT (datetime('now')),
  commands    TEXT,   -- JSON array of executed commands
  output      TEXT,   -- Agent final output
  passed      INTEGER,  -- 1=pass, 0=fail, NULL=not scored
  scores      TEXT    -- JSON with dimension scores
);
