-- user_019: 超量待铺货，抖音20品已上架，有data_id含60个商品
INSERT OR IGNORE INTO users VALUES ('user_019', 'AK_USER019_VALID_KEY', 'configured', '有大批量搜索结果待铺货，当前已上架20品，搜索快照含60个商品', datetime('now'));

INSERT OR IGNORE INTO shops VALUES ('SHOP_019_DY', 'user_019', '我的抖音帽子店', 'douyin', 1, datetime('now', '+180 days'));

-- 20个上架商品（P001-P020）
INSERT OR IGNORE INTO listings VALUES ('LST_019_001', 'SHOP_019_DY', 'P001', datetime('now', '-20 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_019_002', 'SHOP_019_DY', 'P002', datetime('now', '-20 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_019_003', 'SHOP_019_DY', 'P003', datetime('now', '-19 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_019_004', 'SHOP_019_DY', 'P004', datetime('now', '-19 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_019_005', 'SHOP_019_DY', 'P005', datetime('now', '-18 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_019_006', 'SHOP_019_DY', 'P006', datetime('now', '-18 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_019_007', 'SHOP_019_DY', 'P007', datetime('now', '-17 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_019_008', 'SHOP_019_DY', 'P008', datetime('now', '-17 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_019_009', 'SHOP_019_DY', 'P009', datetime('now', '-16 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_019_010', 'SHOP_019_DY', 'P010', datetime('now', '-16 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_019_011', 'SHOP_019_DY', 'P011', datetime('now', '-15 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_019_012', 'SHOP_019_DY', 'P012', datetime('now', '-15 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_019_013', 'SHOP_019_DY', 'P013', datetime('now', '-14 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_019_014', 'SHOP_019_DY', 'P014', datetime('now', '-14 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_019_015', 'SHOP_019_DY', 'P015', datetime('now', '-13 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_019_016', 'SHOP_019_DY', 'P016', datetime('now', '-13 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_019_017', 'SHOP_019_DY', 'P017', datetime('now', '-12 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_019_018', 'SHOP_019_DY', 'P018', datetime('now', '-12 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_019_019', 'SHOP_019_DY', 'P019', datetime('now', '-11 days'), 'active');
INSERT OR IGNORE INTO listings VALUES ('LST_019_020', 'SHOP_019_DY', 'P020', datetime('now', '-11 days'), 'active');

-- 搜索快照：data_id含60个商品（P001-P060），其中P021-P060尚未铺货
INSERT OR IGNORE INTO search_snapshots VALUES (
  '20240101_100000_019',
  'user_019',
  '爆款帽子',
  'douyin',
  datetime('now', '-3 days'),
  '["P001","P002","P003","P004","P005","P006","P007","P008","P009","P010","P011","P012","P013","P014","P015","P016","P017","P018","P019","P020","P021","P022","P023","P024","P025","P026","P027","P028","P029","P030","P031","P032","P033","P034","P035","P036","P037","P038","P039","P040","P041","P042","P043","P044","P045","P046","P047","P048","P049","P050","P051","P052","P053","P054","P055","P056","P057","P058","P059","P060"]'
);

-- 出单记录：5单/天，近14天
INSERT OR IGNORE INTO orders VALUES ('ORD_019_001', 'SHOP_019_DY', 'P002', date('now', '-1 days'), 1, 18.5);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_002', 'SHOP_019_DY', 'P018', date('now', '-1 days'), 1, 30.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_003', 'SHOP_019_DY', 'P007', date('now', '-1 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_004', 'SHOP_019_DY', 'P011', date('now', '-1 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_005', 'SHOP_019_DY', 'P001', date('now', '-1 days'), 1, 25.8);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_006', 'SHOP_019_DY', 'P018', date('now', '-2 days'), 2, 60.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_007', 'SHOP_019_DY', 'P002', date('now', '-2 days'), 1, 18.5);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_008', 'SHOP_019_DY', 'P007', date('now', '-2 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_009', 'SHOP_019_DY', 'P012', date('now', '-2 days'), 1, 18.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_010', 'SHOP_019_DY', 'P002', date('now', '-3 days'), 1, 18.5);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_011', 'SHOP_019_DY', 'P018', date('now', '-3 days'), 1, 30.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_012', 'SHOP_019_DY', 'P011', date('now', '-3 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_013', 'SHOP_019_DY', 'P001', date('now', '-3 days'), 1, 25.8);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_014', 'SHOP_019_DY', 'P007', date('now', '-3 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_015', 'SHOP_019_DY', 'P002', date('now', '-4 days'), 2, 37.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_016', 'SHOP_019_DY', 'P018', date('now', '-4 days'), 1, 30.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_017', 'SHOP_019_DY', 'P007', date('now', '-4 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_018', 'SHOP_019_DY', 'P011', date('now', '-4 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_019', 'SHOP_019_DY', 'P018', date('now', '-5 days'), 2, 60.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_020', 'SHOP_019_DY', 'P002', date('now', '-5 days'), 1, 18.5);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_021', 'SHOP_019_DY', 'P001', date('now', '-5 days'), 1, 25.8);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_022', 'SHOP_019_DY', 'P007', date('now', '-5 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_023', 'SHOP_019_DY', 'P009', date('now', '-5 days'), 1, 20.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_024', 'SHOP_019_DY', 'P002', date('now', '-6 days'), 1, 18.5);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_025', 'SHOP_019_DY', 'P018', date('now', '-6 days'), 1, 30.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_026', 'SHOP_019_DY', 'P011', date('now', '-6 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_027', 'SHOP_019_DY', 'P007', date('now', '-6 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_028', 'SHOP_019_DY', 'P016', date('now', '-6 days'), 1, 26.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_029', 'SHOP_019_DY', 'P018', date('now', '-7 days'), 2, 60.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_030', 'SHOP_019_DY', 'P002', date('now', '-7 days'), 1, 18.5);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_031', 'SHOP_019_DY', 'P001', date('now', '-7 days'), 1, 25.8);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_032', 'SHOP_019_DY', 'P011', date('now', '-7 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_033', 'SHOP_019_DY', 'P002', date('now', '-8 days'), 1, 18.5);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_034', 'SHOP_019_DY', 'P018', date('now', '-8 days'), 1, 30.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_035', 'SHOP_019_DY', 'P007', date('now', '-8 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_036', 'SHOP_019_DY', 'P011', date('now', '-8 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_037', 'SHOP_019_DY', 'P014', date('now', '-8 days'), 1, 24.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_038', 'SHOP_019_DY', 'P002', date('now', '-9 days'), 2, 37.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_039', 'SHOP_019_DY', 'P018', date('now', '-9 days'), 1, 30.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_040', 'SHOP_019_DY', 'P001', date('now', '-9 days'), 1, 25.8);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_041', 'SHOP_019_DY', 'P007', date('now', '-9 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_042', 'SHOP_019_DY', 'P018', date('now', '-10 days'), 2, 60.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_043', 'SHOP_019_DY', 'P002', date('now', '-10 days'), 1, 18.5);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_044', 'SHOP_019_DY', 'P011', date('now', '-10 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_045', 'SHOP_019_DY', 'P007', date('now', '-10 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_046', 'SHOP_019_DY', 'P002', date('now', '-11 days'), 1, 18.5);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_047', 'SHOP_019_DY', 'P018', date('now', '-11 days'), 1, 30.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_048', 'SHOP_019_DY', 'P001', date('now', '-11 days'), 1, 25.8);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_049', 'SHOP_019_DY', 'P007', date('now', '-11 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_050', 'SHOP_019_DY', 'P011', date('now', '-11 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_051', 'SHOP_019_DY', 'P002', date('now', '-12 days'), 2, 37.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_052', 'SHOP_019_DY', 'P018', date('now', '-12 days'), 1, 30.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_053', 'SHOP_019_DY', 'P007', date('now', '-12 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_054', 'SHOP_019_DY', 'P011', date('now', '-12 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_055', 'SHOP_019_DY', 'P018', date('now', '-13 days'), 2, 60.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_056', 'SHOP_019_DY', 'P002', date('now', '-13 days'), 1, 18.5);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_057', 'SHOP_019_DY', 'P001', date('now', '-13 days'), 1, 25.8);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_058', 'SHOP_019_DY', 'P007', date('now', '-13 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_059', 'SHOP_019_DY', 'P002', date('now', '-14 days'), 1, 18.5);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_060', 'SHOP_019_DY', 'P018', date('now', '-14 days'), 1, 30.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_061', 'SHOP_019_DY', 'P011', date('now', '-14 days'), 1, 38.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_062', 'SHOP_019_DY', 'P007', date('now', '-14 days'), 1, 12.0);
INSERT OR IGNORE INTO orders VALUES ('ORD_019_063', 'SHOP_019_DY', 'P009', date('now', '-14 days'), 1, 20.0);
