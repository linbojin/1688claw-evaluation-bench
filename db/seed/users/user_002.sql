-- user_002: 配好AK，绑好1个抖音店，0商品，0出单
INSERT OR IGNORE INTO users VALUES ('user_002', 'AK_USER002_VALID_KEY', 'configured', '配好AK绑好店但还没选品', datetime('now'));

INSERT OR IGNORE INTO shops VALUES ('SHOP_002_DY', 'user_002', '我的抖音小店', 'douyin', 1, datetime('now', '+180 days'));
