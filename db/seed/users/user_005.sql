-- user_005: 授权过期，12个商品，3单/天
INSERT OR IGNORE INTO users VALUES ('user_005', 'AK_USER005_VALID_KEY', 'configured', '授权过期需要重新授权才能铺货', datetime('now'));

INSERT OR IGNORE INTO shops VALUES ('SHOP_005_DY', 'user_005', '我的抖音服装店', 'douyin', 0, datetime('now', '-3 days'));

-- 12个上架商品
INSERT OR IGNORE INTO listings VALUES ('LST_005_001', 'SHOP_005_DY', 'P046', datetime('now', '-30 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_005_002', 'SHOP_005_DY', 'P047', datetime('now', '-30 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_005_003', 'SHOP_005_DY', 'P048', datetime('now', '-29 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_005_004', 'SHOP_005_DY', 'P049', datetime('now', '-28 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_005_005', 'SHOP_005_DY', 'P050', datetime('now', '-28 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_005_006', 'SHOP_005_DY', 'P051', datetime('now', '-27 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_005_007', 'SHOP_005_DY', 'P052', datetime('now', '-26 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_005_008', 'SHOP_005_DY', 'P053', datetime('now', '-25 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_005_009', 'SHOP_005_DY', 'P054', datetime('now', '-24 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_005_010', 'SHOP_005_DY', 'P055', datetime('now', '-23 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_005_011', 'SHOP_005_DY', 'P056', datetime('now', '-22 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_005_012', 'SHOP_005_DY', 'P057', datetime('now', '-21 days'), 'active');

-- 出单记录（3单/天，近30天）
INSERT OR IGNORE INTO orders VALUES ('ORD_005_001', 'SHOP_005_DY', 'P046', date('now', '-1 days'), 1, 85.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_005_002', 'SHOP_005_DY', 'P047', date('now', '-1 days'), 1, 45.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_005_003', 'SHOP_005_DY', 'P050', date('now', '-1 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_005_004', 'SHOP_005_DY', 'P046', date('now', '-2 days'), 2, 170.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_005_005', 'SHOP_005_DY', 'P048', date('now', '-2 days'), 1, 68.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_005_006', 'SHOP_005_DY', 'P055', date('now', '-3 days'), 1, 22.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_005_007', 'SHOP_005_DY', 'P047', date('now', '-3 days'), 1, 45.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_005_008', 'SHOP_005_DY', 'P050', date('now', '-4 days'), 2, 76.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_005_009', 'SHOP_005_DY', 'P046', date('now', '-4 days'), 1, 85.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_005_010', 'SHOP_005_DY', 'P052', date('now', '-5 days'), 1, 52.0);
