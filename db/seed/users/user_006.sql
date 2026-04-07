-- user_006: 单平台成长，抖音30品，8单/天均匀分布
INSERT OR IGNORE INTO users VALUES ('user_006', 'AK_USER006_VALID_KEY', 'configured', '单平台成长期，抖音帽子垂直店，稳定出单', datetime('now'));

INSERT OR IGNORE INTO shops VALUES ('SHOP_006_DY', 'user_006', '我的抖音帽子店', 'douyin', 1, datetime('now', '+180 days'));

-- 30个上架商品（帽子 P001-P030）
INSERT OR IGNORE INTO listings VALUES ('LST_006_001', 'SHOP_006_DY', 'P001', datetime('now', '-30 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_002', 'SHOP_006_DY', 'P002', datetime('now', '-30 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_003', 'SHOP_006_DY', 'P003', datetime('now', '-29 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_004', 'SHOP_006_DY', 'P004', datetime('now', '-29 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_005', 'SHOP_006_DY', 'P005', datetime('now', '-28 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_006', 'SHOP_006_DY', 'P006', datetime('now', '-28 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_007', 'SHOP_006_DY', 'P007', datetime('now', '-27 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_008', 'SHOP_006_DY', 'P008', datetime('now', '-27 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_009', 'SHOP_006_DY', 'P009', datetime('now', '-26 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_010', 'SHOP_006_DY', 'P010', datetime('now', '-26 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_011', 'SHOP_006_DY', 'P011', datetime('now', '-25 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_012', 'SHOP_006_DY', 'P012', datetime('now', '-25 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_013', 'SHOP_006_DY', 'P013', datetime('now', '-24 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_014', 'SHOP_006_DY', 'P014', datetime('now', '-24 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_015', 'SHOP_006_DY', 'P015', datetime('now', '-23 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_016', 'SHOP_006_DY', 'P016', datetime('now', '-23 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_017', 'SHOP_006_DY', 'P017', datetime('now', '-22 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_018', 'SHOP_006_DY', 'P018', datetime('now', '-22 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_019', 'SHOP_006_DY', 'P019', datetime('now', '-21 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_020', 'SHOP_006_DY', 'P020', datetime('now', '-21 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_021', 'SHOP_006_DY', 'P021', datetime('now', '-20 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_022', 'SHOP_006_DY', 'P022', datetime('now', '-20 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_023', 'SHOP_006_DY', 'P023', datetime('now', '-19 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_024', 'SHOP_006_DY', 'P024', datetime('now', '-19 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_025', 'SHOP_006_DY', 'P025', datetime('now', '-18 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_026', 'SHOP_006_DY', 'P026', datetime('now', '-18 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_027', 'SHOP_006_DY', 'P027', datetime('now', '-17 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_028', 'SHOP_006_DY', 'P028', datetime('now', '-17 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_029', 'SHOP_006_DY', 'P029', datetime('now', '-16 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_006_030', 'SHOP_006_DY', 'P030', datetime('now', '-16 days'), 'active');

-- 出单记录：8单/天，近14天，分布在15个SKU，P001/P002/P007/P011/P018/P022/P024/P025/P027 出单较多
-- Day -1: 8 orders
INSERT OR IGNORE INTO orders VALUES ('ORD_006_001', 'SHOP_006_DY', 'P002', date('now', '-1 days'), 1, 18.5);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_002', 'SHOP_006_DY', 'P018', date('now', '-1 days'), 1, 30.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_003', 'SHOP_006_DY', 'P022', date('now', '-1 days'), 2, 44.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_004', 'SHOP_006_DY', 'P025', date('now', '-1 days'), 1, 10.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_005', 'SHOP_006_DY', 'P001', date('now', '-1 days'), 1, 25.8);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_006', 'SHOP_006_DY', 'P007', date('now', '-1 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_007', 'SHOP_006_DY', 'P027', date('now', '-1 days'), 1, 18.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_008', 'SHOP_006_DY', 'P011', date('now', '-1 days'), 1, 38.0);
-- Day -2: 8 orders
INSERT OR IGNORE INTO orders VALUES ('ORD_006_009', 'SHOP_006_DY', 'P002', date('now', '-2 days'), 2, 37.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_010', 'SHOP_006_DY', 'P025', date('now', '-2 days'), 2, 20.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_011', 'SHOP_006_DY', 'P018', date('now', '-2 days'), 1, 30.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_012', 'SHOP_006_DY', 'P024', date('now', '-2 days'), 1, 28.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_013', 'SHOP_006_DY', 'P022', date('now', '-2 days'), 1, 22.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_014', 'SHOP_006_DY', 'P001', date('now', '-2 days'), 1, 25.8);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_015', 'SHOP_006_DY', 'P009', date('now', '-2 days'), 1, 20.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_016', 'SHOP_006_DY', 'P027', date('now', '-2 days'), 1, 18.0);
-- Day -3: 8 orders
INSERT OR IGNORE INTO orders VALUES ('ORD_006_017', 'SHOP_006_DY', 'P018', date('now', '-3 days'), 2, 60.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_018', 'SHOP_006_DY', 'P002', date('now', '-3 days'), 1, 18.5);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_019', 'SHOP_006_DY', 'P025', date('now', '-3 days'), 3, 30.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_020', 'SHOP_006_DY', 'P011', date('now', '-3 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_021', 'SHOP_006_DY', 'P007', date('now', '-3 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_022', 'SHOP_006_DY', 'P022', date('now', '-3 days'), 1, 22.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_023', 'SHOP_006_DY', 'P024', date('now', '-3 days'), 1, 28.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_024', 'SHOP_006_DY', 'P014', date('now', '-3 days'), 1, 24.0);
-- Day -4: 8 orders
INSERT OR IGNORE INTO orders VALUES ('ORD_006_025', 'SHOP_006_DY', 'P001', date('now', '-4 days'), 2, 51.6);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_026', 'SHOP_006_DY', 'P002', date('now', '-4 days'), 1, 18.5);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_027', 'SHOP_006_DY', 'P018', date('now', '-4 days'), 1, 30.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_028', 'SHOP_006_DY', 'P027', date('now', '-4 days'), 2, 36.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_029', 'SHOP_006_DY', 'P022', date('now', '-4 days'), 1, 22.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_030', 'SHOP_006_DY', 'P025', date('now', '-4 days'), 1, 10.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_031', 'SHOP_006_DY', 'P011', date('now', '-4 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_032', 'SHOP_006_DY', 'P019', date('now', '-4 days'), 1, 22.0);
-- Day -5: 8 orders
INSERT OR IGNORE INTO orders VALUES ('ORD_006_033', 'SHOP_006_DY', 'P002', date('now', '-5 days'), 2, 37.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_034', 'SHOP_006_DY', 'P018', date('now', '-5 days'), 1, 30.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_035', 'SHOP_006_DY', 'P025', date('now', '-5 days'), 2, 20.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_036', 'SHOP_006_DY', 'P007', date('now', '-5 days'), 2, 24.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_037', 'SHOP_006_DY', 'P024', date('now', '-5 days'), 1, 28.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_038', 'SHOP_006_DY', 'P001', date('now', '-5 days'), 1, 25.8);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_039', 'SHOP_006_DY', 'P022', date('now', '-5 days'), 1, 22.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_040', 'SHOP_006_DY', 'P012', date('now', '-5 days'), 1, 18.0);
-- Day -6: 8 orders
INSERT OR IGNORE INTO orders VALUES ('ORD_006_041', 'SHOP_006_DY', 'P018', date('now', '-6 days'), 2, 60.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_042', 'SHOP_006_DY', 'P002', date('now', '-6 days'), 1, 18.5);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_043', 'SHOP_006_DY', 'P025', date('now', '-6 days'), 1, 10.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_044', 'SHOP_006_DY', 'P027', date('now', '-6 days'), 1, 18.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_045', 'SHOP_006_DY', 'P011', date('now', '-6 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_046', 'SHOP_006_DY', 'P022', date('now', '-6 days'), 1, 22.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_047', 'SHOP_006_DY', 'P007', date('now', '-6 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_048', 'SHOP_006_DY', 'P029', date('now', '-6 days'), 1, 32.0);
-- Day -7: 8 orders
INSERT OR IGNORE INTO orders VALUES ('ORD_006_049', 'SHOP_006_DY', 'P002', date('now', '-7 days'), 2, 37.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_050', 'SHOP_006_DY', 'P018', date('now', '-7 days'), 1, 30.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_051', 'SHOP_006_DY', 'P025', date('now', '-7 days'), 2, 20.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_052', 'SHOP_006_DY', 'P001', date('now', '-7 days'), 1, 25.8);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_053', 'SHOP_006_DY', 'P024', date('now', '-7 days'), 1, 28.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_054', 'SHOP_006_DY', 'P022', date('now', '-7 days'), 1, 22.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_055', 'SHOP_006_DY', 'P027', date('now', '-7 days'), 1, 18.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_056', 'SHOP_006_DY', 'P011', date('now', '-7 days'), 1, 38.0);
-- Day -8: 8 orders
INSERT OR IGNORE INTO orders VALUES ('ORD_006_057', 'SHOP_006_DY', 'P018', date('now', '-8 days'), 1, 30.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_058', 'SHOP_006_DY', 'P002', date('now', '-8 days'), 2, 37.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_059', 'SHOP_006_DY', 'P025', date('now', '-8 days'), 1, 10.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_060', 'SHOP_006_DY', 'P007', date('now', '-8 days'), 2, 24.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_061', 'SHOP_006_DY', 'P001', date('now', '-8 days'), 1, 25.8);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_062', 'SHOP_006_DY', 'P022', date('now', '-8 days'), 1, 22.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_063', 'SHOP_006_DY', 'P011', date('now', '-8 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_064', 'SHOP_006_DY', 'P016', date('now', '-8 days'), 1, 26.0);
-- Day -9: 8 orders
INSERT OR IGNORE INTO orders VALUES ('ORD_006_065', 'SHOP_006_DY', 'P002', date('now', '-9 days'), 1, 18.5);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_066', 'SHOP_006_DY', 'P018', date('now', '-9 days'), 2, 60.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_067', 'SHOP_006_DY', 'P025', date('now', '-9 days'), 2, 20.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_068', 'SHOP_006_DY', 'P024', date('now', '-9 days'), 1, 28.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_069', 'SHOP_006_DY', 'P027', date('now', '-9 days'), 1, 18.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_070', 'SHOP_006_DY', 'P001', date('now', '-9 days'), 1, 25.8);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_071', 'SHOP_006_DY', 'P022', date('now', '-9 days'), 1, 22.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_072', 'SHOP_006_DY', 'P021', date('now', '-9 days'), 1, 15.0);
-- Day -10: 8 orders
INSERT OR IGNORE INTO orders VALUES ('ORD_006_073', 'SHOP_006_DY', 'P018', date('now', '-10 days'), 1, 30.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_074', 'SHOP_006_DY', 'P002', date('now', '-10 days'), 2, 37.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_075', 'SHOP_006_DY', 'P025', date('now', '-10 days'), 1, 10.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_076', 'SHOP_006_DY', 'P011', date('now', '-10 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_077', 'SHOP_006_DY', 'P007', date('now', '-10 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_078', 'SHOP_006_DY', 'P022', date('now', '-10 days'), 1, 22.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_079', 'SHOP_006_DY', 'P027', date('now', '-10 days'), 1, 18.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_080', 'SHOP_006_DY', 'P024', date('now', '-10 days'), 1, 28.0);
-- Day -11: 8 orders
INSERT OR IGNORE INTO orders VALUES ('ORD_006_081', 'SHOP_006_DY', 'P002', date('now', '-11 days'), 1, 18.5);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_082', 'SHOP_006_DY', 'P018', date('now', '-11 days'), 2, 60.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_083', 'SHOP_006_DY', 'P025', date('now', '-11 days'), 2, 20.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_084', 'SHOP_006_DY', 'P001', date('now', '-11 days'), 1, 25.8);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_085', 'SHOP_006_DY', 'P022', date('now', '-11 days'), 1, 22.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_086', 'SHOP_006_DY', 'P007', date('now', '-11 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_087', 'SHOP_006_DY', 'P011', date('now', '-11 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_088', 'SHOP_006_DY', 'P027', date('now', '-11 days'), 1, 18.0);
-- Day -12: 8 orders
INSERT OR IGNORE INTO orders VALUES ('ORD_006_089', 'SHOP_006_DY', 'P018', date('now', '-12 days'), 1, 30.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_090', 'SHOP_006_DY', 'P002', date('now', '-12 days'), 1, 18.5);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_091', 'SHOP_006_DY', 'P025', date('now', '-12 days'), 1, 10.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_092', 'SHOP_006_DY', 'P024', date('now', '-12 days'), 2, 56.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_093', 'SHOP_006_DY', 'P022', date('now', '-12 days'), 1, 22.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_094', 'SHOP_006_DY', 'P001', date('now', '-12 days'), 1, 25.8);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_095', 'SHOP_006_DY', 'P007', date('now', '-12 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_096', 'SHOP_006_DY', 'P015', date('now', '-12 days'), 1, 16.0);
-- Day -13: 8 orders
INSERT OR IGNORE INTO orders VALUES ('ORD_006_097', 'SHOP_006_DY', 'P002', date('now', '-13 days'), 2, 37.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_098', 'SHOP_006_DY', 'P018', date('now', '-13 days'), 1, 30.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_099', 'SHOP_006_DY', 'P025', date('now', '-13 days'), 2, 20.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_100', 'SHOP_006_DY', 'P011', date('now', '-13 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_101', 'SHOP_006_DY', 'P027', date('now', '-13 days'), 1, 18.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_102', 'SHOP_006_DY', 'P022', date('now', '-13 days'), 1, 22.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_103', 'SHOP_006_DY', 'P001', date('now', '-13 days'), 1, 25.8);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_104', 'SHOP_006_DY', 'P024', date('now', '-13 days'), 1, 28.0);
-- Day -14: 8 orders
INSERT OR IGNORE INTO orders VALUES ('ORD_006_105', 'SHOP_006_DY', 'P018', date('now', '-14 days'), 2, 60.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_106', 'SHOP_006_DY', 'P002', date('now', '-14 days'), 1, 18.5);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_107', 'SHOP_006_DY', 'P025', date('now', '-14 days'), 1, 10.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_108', 'SHOP_006_DY', 'P022', date('now', '-14 days'), 2, 44.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_109', 'SHOP_006_DY', 'P007', date('now', '-14 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_110', 'SHOP_006_DY', 'P001', date('now', '-14 days'), 1, 25.8);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_111', 'SHOP_006_DY', 'P027', date('now', '-14 days'), 1, 18.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_006_112', 'SHOP_006_DY', 'P011', date('now', '-14 days'), 1, 38.0);
