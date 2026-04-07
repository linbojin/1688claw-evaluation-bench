-- user_003: 拼多多店，8个商品，0出单
INSERT OR IGNORE INTO users VALUES ('user_003', 'AK_USER003_VALID_KEY', 'configured', '刚铺了第一批货还没出单', datetime('now'));

INSERT OR IGNORE INTO shops VALUES ('SHOP_003_PDD', 'user_003', '我的拼多多小店', 'pinduoduo', 1, datetime('now', '+180 days'));

-- 8个上架商品（帽子类）
INSERT OR IGNORE INTO listings VALUES ('LST_003_001', 'SHOP_003_PDD', 'P001', datetime('now', '-10 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_003_002', 'SHOP_003_PDD', 'P002', datetime('now', '-10 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_003_003', 'SHOP_003_PDD', 'P003', datetime('now', '-10 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_003_004', 'SHOP_003_PDD', 'P006', datetime('now', '-9 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_003_005', 'SHOP_003_PDD', 'P011', datetime('now', '-9 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_003_006', 'SHOP_003_PDD', 'P018', datetime('now', '-8 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_003_007', 'SHOP_003_PDD', 'P021', datetime('now', '-8 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_003_008', 'SHOP_003_PDD', 'P022', datetime('now', '-7 days'), 'active');
