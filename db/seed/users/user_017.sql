-- user_017: 全部店铺授权过期，2店各30品，历史出单已停止
INSERT OR IGNORE INTO users VALUES ('user_017', 'AK_USER017_VALID_KEY', 'configured', '所有店铺授权已过期，需要重新授权才能继续铺货', datetime('now'));

-- 抖音店铺授权过期5天前
INSERT OR IGNORE INTO shops VALUES ('SHOP_017_DY', 'user_017', '我的抖音服装店', 'douyin', 0, datetime('now', '-5 days'));
-- 拼多多店铺授权过期3天前
INSERT OR IGNORE INTO shops VALUES ('SHOP_017_PDD', 'user_017', '我的拼多多百货店', 'pinduoduo', 0, datetime('now', '-3 days'));

-- 抖音30品 P001-P030
INSERT OR IGNORE INTO listings VALUES ('LST_017_001', 'SHOP_017_DY', 'P001', datetime('now', '-40 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_002', 'SHOP_017_DY', 'P002', datetime('now', '-40 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_003', 'SHOP_017_DY', 'P003', datetime('now', '-39 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_004', 'SHOP_017_DY', 'P004', datetime('now', '-39 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_005', 'SHOP_017_DY', 'P005', datetime('now', '-38 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_006', 'SHOP_017_DY', 'P006', datetime('now', '-38 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_007', 'SHOP_017_DY', 'P007', datetime('now', '-37 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_008', 'SHOP_017_DY', 'P008', datetime('now', '-37 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_009', 'SHOP_017_DY', 'P009', datetime('now', '-36 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_010', 'SHOP_017_DY', 'P010', datetime('now', '-36 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_011', 'SHOP_017_DY', 'P011', datetime('now', '-35 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_012', 'SHOP_017_DY', 'P012', datetime('now', '-35 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_013', 'SHOP_017_DY', 'P013', datetime('now', '-34 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_014', 'SHOP_017_DY', 'P014', datetime('now', '-34 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_015', 'SHOP_017_DY', 'P015', datetime('now', '-33 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_016', 'SHOP_017_DY', 'P016', datetime('now', '-33 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_017', 'SHOP_017_DY', 'P017', datetime('now', '-32 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_018', 'SHOP_017_DY', 'P018', datetime('now', '-32 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_019', 'SHOP_017_DY', 'P019', datetime('now', '-31 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_020', 'SHOP_017_DY', 'P020', datetime('now', '-31 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_021', 'SHOP_017_DY', 'P021', datetime('now', '-30 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_022', 'SHOP_017_DY', 'P022', datetime('now', '-30 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_023', 'SHOP_017_DY', 'P023', datetime('now', '-29 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_024', 'SHOP_017_DY', 'P024', datetime('now', '-29 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_025', 'SHOP_017_DY', 'P025', datetime('now', '-28 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_026', 'SHOP_017_DY', 'P026', datetime('now', '-28 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_027', 'SHOP_017_DY', 'P027', datetime('now', '-27 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_028', 'SHOP_017_DY', 'P028', datetime('now', '-27 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_029', 'SHOP_017_DY', 'P029', datetime('now', '-26 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_030', 'SHOP_017_DY', 'P030', datetime('now', '-26 days'), 'active');

-- 拼多多30品 P031-P060
INSERT OR IGNORE INTO listings VALUES ('LST_017_031', 'SHOP_017_PDD', 'P031', datetime('now', '-35 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_032', 'SHOP_017_PDD', 'P032', datetime('now', '-35 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_033', 'SHOP_017_PDD', 'P033', datetime('now', '-34 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_034', 'SHOP_017_PDD', 'P034', datetime('now', '-34 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_035', 'SHOP_017_PDD', 'P035', datetime('now', '-33 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_036', 'SHOP_017_PDD', 'P036', datetime('now', '-33 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_037', 'SHOP_017_PDD', 'P037', datetime('now', '-32 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_038', 'SHOP_017_PDD', 'P038', datetime('now', '-32 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_039', 'SHOP_017_PDD', 'P039', datetime('now', '-31 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_040', 'SHOP_017_PDD', 'P040', datetime('now', '-31 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_041', 'SHOP_017_PDD', 'P041', datetime('now', '-30 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_042', 'SHOP_017_PDD', 'P042', datetime('now', '-30 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_043', 'SHOP_017_PDD', 'P043', datetime('now', '-29 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_044', 'SHOP_017_PDD', 'P044', datetime('now', '-29 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_045', 'SHOP_017_PDD', 'P045', datetime('now', '-28 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_046', 'SHOP_017_PDD', 'P046', datetime('now', '-28 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_047', 'SHOP_017_PDD', 'P047', datetime('now', '-27 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_048', 'SHOP_017_PDD', 'P048', datetime('now', '-27 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_049', 'SHOP_017_PDD', 'P049', datetime('now', '-26 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_050', 'SHOP_017_PDD', 'P050', datetime('now', '-26 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_051', 'SHOP_017_PDD', 'P051', datetime('now', '-25 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_052', 'SHOP_017_PDD', 'P052', datetime('now', '-25 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_053', 'SHOP_017_PDD', 'P053', datetime('now', '-24 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_054', 'SHOP_017_PDD', 'P054', datetime('now', '-24 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_055', 'SHOP_017_PDD', 'P055', datetime('now', '-23 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_056', 'SHOP_017_PDD', 'P056', datetime('now', '-23 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_057', 'SHOP_017_PDD', 'P057', datetime('now', '-22 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_058', 'SHOP_017_PDD', 'P058', datetime('now', '-22 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_059', 'SHOP_017_PDD', 'P059', datetime('now', '-21 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_017_060', 'SHOP_017_PDD', 'P060', datetime('now', '-21 days'), 'active');

-- 历史出单（授权过期前，10-15天前，约10单/天）
-- 抖音历史订单（day -10 到 -15）
INSERT OR IGNORE INTO orders VALUES ('ORD_017_001', 'SHOP_017_DY', 'P002', date('now', '-10 days'), 2, 37.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_002', 'SHOP_017_DY', 'P018', date('now', '-10 days'), 2, 60.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_003', 'SHOP_017_DY', 'P022', date('now', '-10 days'), 1, 22.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_004', 'SHOP_017_DY', 'P025', date('now', '-10 days'), 2, 20.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_005', 'SHOP_017_DY', 'P007', date('now', '-10 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_006', 'SHOP_017_DY', 'P011', date('now', '-10 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_007', 'SHOP_017_DY', 'P002', date('now', '-11 days'), 2, 37.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_008', 'SHOP_017_DY', 'P018', date('now', '-11 days'), 2, 60.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_009', 'SHOP_017_DY', 'P027', date('now', '-11 days'), 2, 36.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_010', 'SHOP_017_DY', 'P025', date('now', '-11 days'), 1, 10.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_011', 'SHOP_017_DY', 'P001', date('now', '-11 days'), 1, 25.8);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_012', 'SHOP_017_DY', 'P024', date('now', '-11 days'), 1, 28.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_013', 'SHOP_017_DY', 'P002', date('now', '-12 days'), 3, 55.5);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_014', 'SHOP_017_DY', 'P018', date('now', '-12 days'), 2, 60.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_015', 'SHOP_017_DY', 'P022', date('now', '-12 days'), 2, 44.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_016', 'SHOP_017_DY', 'P025', date('now', '-12 days'), 1, 10.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_017', 'SHOP_017_DY', 'P011', date('now', '-12 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_018', 'SHOP_017_DY', 'P007', date('now', '-12 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_019', 'SHOP_017_DY', 'P002', date('now', '-13 days'), 2, 37.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_020', 'SHOP_017_DY', 'P018', date('now', '-13 days'), 2, 60.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_021', 'SHOP_017_DY', 'P025', date('now', '-13 days'), 2, 20.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_022', 'SHOP_017_DY', 'P027', date('now', '-13 days'), 1, 18.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_023', 'SHOP_017_DY', 'P024', date('now', '-13 days'), 1, 28.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_024', 'SHOP_017_DY', 'P022', date('now', '-13 days'), 2, 44.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_025', 'SHOP_017_DY', 'P002', date('now', '-14 days'), 2, 37.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_026', 'SHOP_017_DY', 'P018', date('now', '-14 days'), 2, 60.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_027', 'SHOP_017_DY', 'P022', date('now', '-14 days'), 2, 44.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_028', 'SHOP_017_DY', 'P025', date('now', '-14 days'), 1, 10.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_029', 'SHOP_017_DY', 'P001', date('now', '-14 days'), 1, 25.8);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_030', 'SHOP_017_DY', 'P011', date('now', '-14 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_031', 'SHOP_017_DY', 'P007', date('now', '-15 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_032', 'SHOP_017_DY', 'P002', date('now', '-15 days'), 2, 37.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_033', 'SHOP_017_DY', 'P018', date('now', '-15 days'), 2, 60.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_034', 'SHOP_017_DY', 'P025', date('now', '-15 days'), 2, 20.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_035', 'SHOP_017_DY', 'P022', date('now', '-15 days'), 2, 44.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_036', 'SHOP_017_DY', 'P027', date('now', '-15 days'), 1, 18.0);

-- 拼多多历史订单（day -10 到 -15）
INSERT OR IGNORE INTO orders VALUES ('ORD_017_037', 'SHOP_017_PDD', 'P035', date('now', '-10 days'), 2, 90.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_038', 'SHOP_017_PDD', 'P043', date('now', '-10 days'), 2, 50.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_039', 'SHOP_017_PDD', 'P047', date('now', '-10 days'), 1, 45.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_040', 'SHOP_017_PDD', 'P050', date('now', '-10 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_041', 'SHOP_017_PDD', 'P055', date('now', '-11 days'), 2, 44.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_042', 'SHOP_017_PDD', 'P035', date('now', '-11 days'), 1, 45.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_043', 'SHOP_017_PDD', 'P046', date('now', '-11 days'), 1, 85.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_044', 'SHOP_017_PDD', 'P043', date('now', '-11 days'), 1, 25.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_045', 'SHOP_017_PDD', 'P035', date('now', '-12 days'), 2, 90.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_046', 'SHOP_017_PDD', 'P050', date('now', '-12 days'), 2, 76.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_047', 'SHOP_017_PDD', 'P047', date('now', '-12 days'), 1, 45.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_048', 'SHOP_017_PDD', 'P055', date('now', '-12 days'), 1, 22.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_049', 'SHOP_017_PDD', 'P043', date('now', '-13 days'), 2, 50.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_050', 'SHOP_017_PDD', 'P035', date('now', '-13 days'), 1, 45.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_051', 'SHOP_017_PDD', 'P046', date('now', '-13 days'), 1, 85.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_052', 'SHOP_017_PDD', 'P048', date('now', '-13 days'), 1, 68.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_053', 'SHOP_017_PDD', 'P035', date('now', '-14 days'), 2, 90.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_054', 'SHOP_017_PDD', 'P043', date('now', '-14 days'), 1, 25.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_055', 'SHOP_017_PDD', 'P047', date('now', '-14 days'), 1, 45.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_056', 'SHOP_017_PDD', 'P055', date('now', '-14 days'), 2, 44.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_057', 'SHOP_017_PDD', 'P050', date('now', '-15 days'), 2, 76.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_058', 'SHOP_017_PDD', 'P035', date('now', '-15 days'), 1, 45.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_059', 'SHOP_017_PDD', 'P043', date('now', '-15 days'), 1, 25.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_017_060', 'SHOP_017_PDD', 'P039', date('now', '-15 days'), 1, 28.0);
