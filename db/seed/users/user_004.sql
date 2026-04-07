-- user_004: 双平台新手，抖音+小红书，各5个商品，0出单
INSERT OR IGNORE INTO users VALUES ('user_004', 'AK_USER004_VALID_KEY', 'configured', '双平台新手两个店都刚开', datetime('now'));

INSERT OR IGNORE INTO shops VALUES ('SHOP_004_DY', 'user_004', '我的抖音潮品店', 'douyin', 1, datetime('now', '+180 days'));
INSERT OR IGNORE INTO shops VALUES ('SHOP_004_XHS', 'user_004', '我的小红书精品店', 'xiaohongshu', 1, datetime('now', '+180 days'));

-- 抖音5个商品（帽子）
INSERT OR IGNORE INTO listings VALUES ('LST_004_DY_001', 'SHOP_004_DY', 'P001', datetime('now', '-5 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_004_DY_002', 'SHOP_004_DY', 'P002', datetime('now', '-5 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_004_DY_003', 'SHOP_004_DY', 'P007', datetime('now', '-4 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_004_DY_004', 'SHOP_004_DY', 'P011', datetime('now', '-4 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_004_DY_005', 'SHOP_004_DY', 'P018', datetime('now', '-3 days'), 'active');

-- 小红书5个商品（家居）
INSERT OR IGNORE INTO listings VALUES ('LST_004_XHS_001', 'SHOP_004_XHS', 'P061', datetime('now', '-5 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_004_XHS_002', 'SHOP_004_XHS', 'P062', datetime('now', '-5 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_004_XHS_003', 'SHOP_004_XHS', 'P064', datetime('now', '-4 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_004_XHS_004', 'SHOP_004_XHS', 'P067', datetime('now', '-4 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_004_XHS_005', 'SHOP_004_XHS', 'P071', datetime('now', '-3 days'), 'active');
