# 1688-shopkeeper Benchmark 设计方案 v2
## 参考框架：τ-Bench + OSWorld + PinchBench

---

## Context

评测对象：装有 1688-shopkeeper skill 的 OpenClaw 完整端到端产品能力。
目标：20个模拟用户 × 5个复杂任务 = 100条 Task，配套本地状态数据库，支持状态传播（铺货后日报可读到）、完整可重置（每次复现初始状态）。

---

## 一、本地数据库设计

使用 **SQLite**（文件级、无服务依赖、易于重置）。

### 数据库 Schema

```sql
-- 用户表
CREATE TABLE users (
  user_id       TEXT PRIMARY KEY,     -- "user_001"
  ak            TEXT,                 -- 1688 AK 密钥
  ak_status     TEXT,                 -- configured / missing / expired
  created_at    TEXT
);

-- 店铺表
CREATE TABLE shops (
  shop_code     TEXT PRIMARY KEY,     -- "SHOP_001"
  user_id       TEXT,
  name          TEXT,
  channel       TEXT,                 -- douyin / pinduoduo / xiaohongshu / taobao
  is_authorized INTEGER,              -- 1=valid, 0=expired
  auth_expires_at TEXT,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 1688商品池（mock 用，代表1688上可搜索到的商品）
CREATE TABLE products_pool (
  item_id       TEXT PRIMARY KEY,
  title         TEXT,
  price         REAL,
  category      TEXT,
  last30DaysSales INTEGER,
  goodRates     REAL,
  repurchaseRate REAL,
  downstreamOffer INTEGER,
  remarkCnt     INTEGER,
  image_url     TEXT
);

-- 搜索快照（search 命令生成）
CREATE TABLE search_snapshots (
  data_id       TEXT PRIMARY KEY,     -- "20240101_120000_001"
  user_id       TEXT,
  query         TEXT,
  channel       TEXT,
  created_at    TEXT,
  product_ids   TEXT                  -- JSON array of item_ids
);

-- 上架记录（publish 命令写入）
CREATE TABLE listings (
  listing_id    TEXT PRIMARY KEY,
  shop_code     TEXT,
  item_id       TEXT,
  listed_at     TEXT,
  status        TEXT,                 -- active / removed
  FOREIGN KEY (shop_code) REFERENCES shops(shop_code)
);

-- 出单记录（用于 shop_daily 读取）
CREATE TABLE orders (
  order_id      TEXT PRIMARY KEY,
  shop_code     TEXT,
  item_id       TEXT,
  order_date    TEXT,
  quantity      INTEGER,
  revenue       REAL,
  FOREIGN KEY (shop_code) REFERENCES shops(shop_code)
);
```

### 重置机制

```
benchmark/
├── db/
│   ├── benchmark.db          # 运行时数据库（被测试修改）
│   └── seed/
│       ├── schema.sql        # 建表 DDL
│       ├── products_pool.sql # 1688 商品池（300条固定mock商品）
│       └── users/
│           ├── user_001.sql  # 每个用户的初始状态
│           ├── user_002.sql
│           └── ...
├── reset.sh                  # 重置脚本：drop + rebuild + seed
└── reset_user.sh <user_id>   # 单用户重置（不影响其他）
```

`reset.sh` 内容：
```bash
rm -f db/benchmark.db
sqlite3 db/benchmark.db < db/seed/schema.sql
sqlite3 db/benchmark.db < db/seed/products_pool.sql
for f in db/seed/users/*.sql; do
  sqlite3 db/benchmark.db < "$f"
done
```

---

## 二、20个模拟用户画像

### A. 新店起步期（5人）

| user_id | 画像 | AK状态 | 绑定店铺 | 上架商品 | 出单情况 |
|---------|------|--------|---------|---------|---------|
| user_001 | 完全新手，刚知道这个产品 | 未配置 | 0 | 0 | 0 |
| user_002 | 配好AK、绑好1个抖音店但还没选品 | 已配置 | 1（抖音）| 0 | 0 |
| user_003 | 刚铺了第一批货，还没出单 | 已配置 | 1（拼多多）| 8 | 0 |
| user_004 | 双平台新手，两个店都刚开 | 已配置 | 2（抖音+小红书）| 各5 | 0 |
| user_005 | 授权过期，需要重新授权才能铺货 | 已配置 | 1（抖音，已过期）| 12 | 3单/天 |

### B. 成长探索期（5人）

| user_id | 画像 | AK状态 | 绑定店铺 | 上架商品 | 出单情况 |
|---------|------|--------|---------|---------|---------|
| user_006 | 单平台成长中，找到感觉了 | 已配置 | 1（抖音）| 30 | 8单/天，均匀分布 |
| user_007 | 多平台运营，摸索哪个平台更好 | 已配置 | 2（抖音+拼多多）| 各15 | 抖音5单/天，拼多多2单/天 |
| user_008 | 有2款爆款苗头，想复制选品方法 | 已配置 | 1（抖音）| 35 | 20单/天（集中在2款） |
| user_009 | 专注家居类目，小红书垂直店 | 已配置 | 1（小红书）| 25（全是家居）| 6单/天 |
| user_010 | 快速扩张，3个店都在铺 | 已配置 | 3（抖音+拼多多+淘宝）| 各25 | 合计15单/天 |

### C. 成熟运营期（5人）

| user_id | 画像 | AK状态 | 绑定店铺 | 上架商品 | 出单情况 |
|---------|------|--------|---------|---------|---------|
| user_011 | 稳定单平台，已有成熟打法 | 已配置 | 1（抖音）| 50 | 45单/天，稳定 |
| user_012 | 双平台成熟，利润不错 | 已配置 | 2（抖音+淘宝）| 各50 | 合计60单/天 |
| user_013 | 多平台老手，有爆款有滞销 | 已配置 | 3（全平台）| 各50 | 合计80单/天，分布不均 |
| user_014 | 季节性经营，大码女装 | 已配置 | 1（拼多多）| 50（大码女装）| 旺季80单/天，淡季10单 |
| user_015 | 精品选品，小红书高客单价 | 已配置 | 1（小红书）| 20（精品家居）| 10单/天，高客单均值150元 |

### D. 边缘/异常状态（5人）

| user_id | 画像 | AK状态 | 绑定店铺 | 上架商品 | 特殊情况 |
|---------|------|--------|---------|---------|---------|
| user_016 | AK 即将过期，还能用但不稳定 | 即将过期 | 1（抖音）| 40 | 部分接口返回401 |
| user_017 | 全部店铺授权过期，急需续期 | 已配置 | 2（抖音+拼多多，全过期）| 各30 | publish 必返回511 |
| user_018 | 有AK但还没绑定任何店铺 | 已配置 | 0 | 0 | shops 返回空 |
| user_019 | 搜了大批量商品待铺货（超20条限制）| 已配置 | 1（抖音）| 20 | 有 data_id 含60个商品 |
| user_020 | 混合状态：1个店正常、1个过期 | 已配置 | 2（抖音正常+拼多多过期）| 各20 | 歧义消解场景 |

---

## 三、100条 Task 设计

### 每个用户的5个 Task 类型

每个用户按其状态特点设计5个有递进关系或独立的任务，难度从基础到复杂。

---

#### user_001（完全新手，AK未配置）

| # | Task | 多轮对话摘要 | 关键状态变化 |
|---|------|------------|------------|
| T001-1 | 首次探索：询问能帮什么 | 用户问"你能帮我做什么" → 介绍功能 | 无 |
| T001-2 | 引导配置AK | 用户尝试搜索 → 收到AK引导 → 提供AK → configure | ak_status → configured |
| T001-3 | 首次选品 | 配好AK后搜索"爆款帽子" → 搜索结果 → 选品分析 | 生成 data_id |
| T001-4 | 找店铺 + 铺货 | 查绑定店铺（0个）→ 收到开店引导 | 无（需先开店）|
| T001-5 | 了解选品风险 | "哪些商品有风险不能卖" → 加载FAQ回答 | 无 |

#### user_002（有AK有抖音店，0商品0出单）

| # | Task | 多轮对话摘要 | 关键状态变化 |
|---|------|------------|------------|
| T002-1 | 第一次选品+铺货全链路 | 搜索露营椅 → 看结果 → 查店铺 → dry-run → publish | listings +10 |
| T002-2 | 查商机热榜+选品 | opportunities → 发现帽子热 → 搜帽子 → 铺货 | listings +8 |
| T002-3 | 看趋势+决策 | trend "大码女装" → 价格分布分析 → 决定不进 | 无 |
| T002-4 | 铺货后出日报（无出单） | shop_daily → 0出单 → 获得新店建议 | 无 |
| T002-5 | 限量铺货（只铺指定几个）| 搜索25个商品 → 用户选5个 → publish --item-ids | listings +5 |

#### user_003（拼多多店，8个商品，0出单）

| # | Task | 多轮对话摘要 | 关键状态变化 |
|---|------|------------|------------|
| T003-1 | 日报 + 选品建议 | shop_daily → 0出单 → 建议选爆款补充 → 搜索 | 生成 data_id |
| T003-2 | 跨平台考虑 | "要不要再开个抖音店" → 加载 platform-selection FAQ | 无 |
| T003-3 | 选品+看详情+铺货 | search → prod_detail（看2个） → publish | listings +12 |
| T003-4 | 运费相关问题 | "偏远地区怎么发货" → 加载 fulfillment FAQ | 无 |
| T003-5 | 换类目探索 | 原来是家居，想搜女装 → search + 选品分析 | 新 data_id |

#### user_004（双平台，各5个商品，0出单）

| # | Task | 多轮对话摘要 | 关键状态变化 |
|---|------|------------|------------|
| T004-1 | 指定平台铺货 | "把这批货铺到抖音（不是小红书）" → 歧义消解 → publish | 抖音 listings +8 |
| T004-2 | 双平台对比选品 | search 同款 → "哪个平台更适合卖这个" → FAQ分析 | 无 |
| T004-3 | 全平台铺货 | 同一批商品分别铺到两个店 → 两次 publish | 两店各 +10 |
| T004-4 | 商机 + 趋势 + 双平台 | opportunities → trend → 搜索 → 铺到对的平台 | listings |
| T004-5 | 新品首发选品策略 | "我想主打节日礼盒，怎么选" → product-selection FAQ | 无 |

#### user_005（授权过期店铺）

| # | Task | 多轮对话摘要 | 关键状态变化 |
|---|------|------------|------------|
| T005-1 | 发现授权过期 | 尝试铺货 → 511错误 → 引导重新授权 | 无（用户需线下操作）|
| T005-2 | 授权恢复后铺货 | db 中手动恢复授权 → 重新 publish | listings |
| T005-3 | 日报读已有出单数据 | shop_daily → 读到3单/天 → 分析提升建议 | 无 |
| T005-4 | 趋势对比当前品 | trend 对应类目 → 与现有商品对比 → 建议补品 | 无 |
| T005-5 | 综合诊断 | shop_daily + opportunities + 针对性 search | 新 data_id |

#### user_006（抖音30品，8单/天）

| # | Task | 多轮对话摘要 | 关键状态变化 |
|---|------|------------|------------|
| T006-1 | 日报读取+深度分析 | shop_daily → 8单/天分布 → "哪个品最好" → 追问 prod_detail | 无 |
| T006-2 | 补品选品 | "我想补10个新品进来" → search → 选品分析 → publish | listings +10 |
| T006-3 | 类目趋势洞察 | trend "露营" → 价格分布 → 与现有品对比 → 决策 | 无 |
| T006-4 | 上架后日报变化 | T006-2 铺货后 → shop_daily → listings 增加体现在日报 | 无（读已变化状态）|
| T006-5 | 滞销品处理建议 | shop_daily → 发现20个品0出单 → 建议策略 | 无 |

#### user_007（双平台，各15品，不均衡出单）

| # | Task | 多轮对话摘要 | 关键状态变化 |
|---|------|------------|------------|
| T007-1 | 平台对比日报 | shop_daily → 抖音5单拼多多2单 → 深度对比建议 | 无 |
| T007-2 | 为强势平台加码 | "给抖音再铺10个品" → search → publish（指定抖音）| 抖音 listings +10 |
| T007-3 | 弱势平台优化 | "为什么拼多多出单少" → platform-selection FAQ + 选品建议 | 无 |
| T007-4 | 跨平台同款选品 | 搜同一批货 → 分别铺到两平台 | 两平台各 listings |
| T007-5 | 商机驱动全链路 | opportunities → 发现热品 → search → 决策 → 铺到合适平台 | listings |

#### user_008（抖音35品，爆款集中）

| # | Task | 多轮对话摘要 | 关键状态变化 |
|---|------|------------|------------|
| T008-1 | 解析爆款规律 | shop_daily → 2款高出单 → prod_detail 这2款 → 分析共性 | 无 |
| T008-2 | 复制爆款选品 | "按爆款的特征帮我再找类似的" → search（精准关键词）| data_id |
| T008-3 | 趋势验证选品 | trend 对应类目 → 验证方向 → 补充选品 → publish | listings |
| T008-4 | 商机热榜发现新方向 | opportunities → 找到新类目 → search → 是否符合爆款特征 | data_id |
| T008-5 | 扩品后日报 | T008-3 铺货后 → shop_daily → 新品出现在日报 → 效果评估 | 无 |

#### user_009（小红书家居，25品，6单/天）

| # | Task | 多轮对话摘要 | 关键状态变化 |
|---|------|------------|------------|
| T009-1 | 垂直类目深耕 | shop_daily → 家居6单 → trend "家居" → 深化选品方向 | 无 |
| T009-2 | 节日选品规划 | "双11要选什么品" → product-selection FAQ + search | data_id |
| T009-3 | 内容合规问题 | "小红书商品标题怎么写才不会被审核" → content-compliance FAQ | 无 |
| T009-4 | 拓品边界试探 | "我想试试厨房类目" → trend "厨房" → search → 决策 | data_id |
| T009-5 | 铺货后效果闭环 | T009-2 铺货后几轮后 → shop_daily → 新品表现 | 无 |

#### user_010（3店铺，各25品，15单/天）

| # | Task | 多轮对话摘要 | 关键状态变化 |
|---|------|------------|------------|
| T010-1 | 多店日报综合分析 | shop_daily → 3店数据 → 哪个店重点投入 | 无 |
| T010-2 | 全平台同步铺货 | search 一批货 → 铺到3个店 → 3次 publish | 3店各 listings |
| T010-3 | 渠道差异化选品 | "各平台应该选不同品吗" → platform-selection FAQ + trend | 无 |
| T010-4 | 超量铺货处理 | 用户想铺25个到一个店 → 系统截断20个 → 分批提示 | listings +20 |
| T010-5 | 商机 → 全链路 | opportunities → trend → search → 铺到最合适的平台 | listings |

#### user_011（稳定抖音50品，45单/天）

| # | Task | 多轮对话摘要 | 关键状态变化 |
|---|------|------------|------------|
| T011-1 | 精细化日报分析 | shop_daily → 45单分布 → 找动销规律 → 选品建议 | 无 |
| T011-2 | 替换滞销品 | "把出单最差的10个品换掉" → search → publish new → （手动下架旧品提示）| listings +10 |
| T011-3 | 趋势捕捉 | trend "秋冬服装" → 结合现有品结构 → 补充新品 → publish | listings |
| T011-4 | 价格策略 | "竞品价格怎么样" → trend 价格分布 → listing-template FAQ | 无 |
| T011-5 | 扩品后日报变化验证 | T011-2 执行后 → shop_daily → 日报中listing变化体现 | 无 |

#### user_012（双平台成熟，各50品，60单/天）

| # | Task | 多轮对话摘要 | 关键状态变化 |
|---|------|------------|------------|
| T012-1 | 双平台差异洞察 | shop_daily → 抖音vs淘宝出单对比 → 策略建议 | 无 |
| T012-2 | 批量更新商品 | 搜新品 → 铺到业绩好的平台 | listings |
| T012-3 | 售后问题应对 | "买家申请仅退款怎么办" → after-sales FAQ | 无 |
| T012-4 | 商机 + 双平台决策 | opportunities → 判断热品更适合哪个平台 → 分平台铺 | listings |
| T012-5 | 综合经营诊断 | shop_daily + trend + opportunities 三合一分析 | 无 |

#### user_013（多平台老手，有爆款有滞销）

| # | Task | 多轮对话摘要 | 关键状态变化 |
|---|------|------------|------------|
| T013-1 | 诊断滞销原因 | shop_daily → 发现某类目滞销 → trend → 确认类目下行 | 无 |
| T013-2 | 爆款二次铺量 | prod_detail 爆款 → 找同类替代品 → search → publish | listings |
| T013-3 | 平台选择优化 | 某品在抖音滞销 → "要不要换到拼多多" → platform FAQ + 分析 | 无 |
| T013-4 | 新品类快速验证 | trend 新类目 → search → 铺小批量测试 | listings +5（测试批）|
| T013-5 | 周期性复盘 | shop_daily → 多维分析 → 制定下周选品计划（search多次）| 多个 data_id |

#### user_014（季节性大码女装，拼多多，旺季）

| # | Task | 多轮对话摘要 | 关键状态变化 |
|---|------|------------|------------|
| T014-1 | 旺季前备货 | "节前要多铺货" → search "大码女装" → 大批铺货 | listings +20 |
| T014-2 | 旺季日报分析 | shop_daily（高出单期）→ 哪款卖最好 → 补货建议 | 无 |
| T014-3 | 趋势确认时机 | trend "大码女装" → 价格分布 → 是否还在上行期 | 无 |
| T014-4 | 淡季准备 | "旺季结束了该怎么办" → product-selection FAQ（换类目建议）| 无 |
| T014-5 | 售后高峰应对 | 旺季出单多 → "退货率高怎么办" → after-sales FAQ | 无 |

#### user_015（小红书精品家居，20品，高客单）

| # | Task | 多轮对话摘要 | 关键状态变化 |
|---|------|------------|------------|
| T015-1 | 精品选品标准 | shop_daily → 高客单表现 → "怎么选更多高品质品" → product-selection FAQ | 无 |
| T015-2 | 内容合规严格检查 | "小红书对图片有什么要求" → content-compliance FAQ | 无 |
| T015-3 | 限量铺货精选 | search 家居 → 只选最优2-3款 → publish | listings +3 |
| T015-4 | 定价策略 | "高端定价怎么设置" → listing-template FAQ（倍率建议）| 无 |
| T015-5 | 口碑维护 | "怎么维持好评率" → after-sales + new-store FAQ | 无 |

#### user_016（AK即将过期）

| # | Task | 多轮对话摘要 | 关键状态变化 |
|---|------|------------|------------|
| T016-1 | 正常搜索（偶发401）| search → 返回401 → 引导重新获取AK | 无 |
| T016-2 | 重新配置AK | 用户提供新AK → configure → 验证 | ak_status → configured |
| T016-3 | 配置后恢复搜索 | configure 后 → 继续原来的 search 意图 | data_id |
| T016-4 | 铺货流程不中断 | AK重置后 → 找之前的 data_id → publish | listings |
| T016-5 | 日报正常读取 | shop_daily（AK恢复后）→ 读40品、正常出单 | 无 |

#### user_017（全部授权过期）

| # | Task | 多轮对话摘要 | 关键状态变化 |
|---|------|------------|------------|
| T017-1 | 发现授权全过期 | shops → 全部 is_authorized=false → 引导重新授权 | 无 |
| T017-2 | publish 511 处理 | 尝试铺货 → 511 → 明确引导步骤 | 无 |
| T017-3 | 授权恢复后重试 | db 恢复授权 → publish 正常执行 | listings |
| T017-4 | 日报读历史数据 | shop_daily（授权过期期间仍有历史数据）→ 正常分析 | 无 |
| T017-5 | 搜索不受授权影响 | search 不需要店铺授权 → 正常工作 → 结果备用 | data_id |

#### user_018（有AK无绑定店铺）

| # | Task | 多轮对话摘要 | 关键状态变化 |
|---|------|------------|------------|
| T018-1 | 先搜索再发现无店 | search 成功 → 想铺货 → shops 返回0 → 开店引导 | 无 |
| T018-2 | 只做选品研究 | search + trend + opportunities（纯只读）| data_id |
| T018-3 | 日报处理（无店）| shop_daily → 无店铺数据 → 友好提示 + 开店引导 | 无 |
| T018-4 | FAQ咨询 | "要开哪个平台的店" → platform-selection FAQ | 无 |
| T018-5 | 商机发现 + 选品规划 | opportunities → trend → search → 为未来开店做准备 | 多个 data_id |

#### user_019（超量待铺货，60个商品的 data_id）

| # | Task | 多轮对话摘要 | 关键状态变化 |
|---|------|------------|------------|
| T019-1 | 全量铺货尝试 | publish data_id（60个）→ 自动截断20 → 提示分批 | listings +20 |
| T019-2 | 分批铺货 | 第一批20个后 → 用 --item-ids 指定下一批20个 | listings +20 |
| T019-3 | 筛选铺货 | "帮我从这60个里选最好的10个铺" → prod_detail → 选品 → publish | listings +10 |
| T019-4 | 日报读取全量上架后状态 | T019-1+2后 → shop_daily → 40个新品在日报中体现 | 无 |
| T019-5 | 下批次选品 | 当前60个铺完 → 新一轮 search → 新 data_id | data_id |

#### user_020（混合授权状态）

| # | Task | 多轮对话摘要 | 关键状态变化 |
|---|------|------------|------------|
| T020-1 | 歧义消解铺货（单次追问）| publish → 2个店铺，1个正常1个过期 → 追问选哪个 → 选正常的 | listings |
| T020-2 | 精确指定店铺 | "铺到抖音那个店" → 目标唯一 → dry-run → 直接执行 | listings |
| T020-3 | 跨店对比日报 | shop_daily → 两店数据，过期店无新出单 → 分析差异 | 无 |
| T020-4 | 过期店恢复授权 | "我重新授权了拼多多店" → db 更新 → publish 到拼多多 | listings |
| T020-5 | 授权全恢复后双店铺货 | 两店均正常后 → 同一批货铺到两店 | 两店各 listings |

---

## 四、状态传播机制

关键：Task 之间的状态变化会影响后续 Task 读到的数据。

| 动作 | 数据库写入 | 后续影响 |
|------|-----------|---------|
| `configure <AK>` | users.ak_status = 'configured' | 后续所有命令可用 |
| `search` | INSERT INTO search_snapshots | 后续 publish 可用 data_id |
| `publish` | INSERT INTO listings (批量) | shop_daily 中 listings 数增加 |
| `publish --dry-run` | 不写入 | 不影响后续状态 |
| 用户下架（手动）| listings.status = 'removed' | 日报中该品消失 |

**shop_daily 数据来源逻辑：**
```
用户的shop_daily数据 =
  shops（该用户的店铺列表）
  + listings（该店铺的上架商品，从 db 实时读取）
  + orders（该店铺的出单记录，从 db 实时读取）
```

因此 T006-4（铺货后日报变化）这类任务，评测时必须验证：
`listings 表新增记录` → `shop_daily 返回的 markdown 中商品数量增加`

---

## 五、评测执行流程

```
for each task in task_set:
  1. reset_user(user_id)           # 恢复该用户初始状态
  2. inject world_state into mock  # 加载 mock 响应配置
  3. run_conversation(turns)       # 执行对话（含 k=3 次重复）
  4. record(commands, outputs)     # 记录命令序列 + Agent 输出
  5. run_automated_checks()        # 规则脚本验证
  6. run_llm_judge()               # LLM 评判输出质量
  7. score(task)                   # 汇总分数
  8. update_db_from_actions()      # 将本次 Task 的状态变更写入 db
                                   # （用于依赖上一步的 Task）
```

---

## 六、评测指标

| 指标 | 计算 | 目标 |
|------|------|------|
| Task Completion Rate | 通过 Task / 总 Task | ≥ 80% |
| Tool Call Accuracy | 命令+参数完全正确 / 总 Task | ≥ 90% |
| Safety Compliance | dry-run 执行 / publish Task | **100%** |
| State Propagation Accuracy | 状态变化后日报读取正确 / 相关 Task | ≥ 85% |
| Error Recovery Rate | 正确处理异常 / 异常 Task | ≥ 90% |
| pass^3 | 同场景3次全通过 / 总 Task | ≥ 70% |
| Hallucination Rate | 编造数据的 Task / 总 Task | ≤ 5% |

---

## 七、关键文件结构

```
benchmark/
├── db/
│   ├── benchmark.db
│   ├── seed/
│   │   ├── schema.sql
│   │   ├── products_pool.sql        # 300个mock商品
│   │   └── users/
│   │       ├── user_001.sql ~ user_020.sql
├── tasks/
│   ├── user_001/
│   │   ├── T001-1.yaml ~ T001-5.yaml
│   └── .../
├── mock/
│   ├── interceptor.py               # 拦截 cli.py，路由到 db-backed mock
│   └── response_builders/           # 按命令类型生成 mock 响应
├── evaluator/
│   ├── automated_checks.py          # 规则验证脚本
│   ├── llm_judge.py                 # claude-opus-4-6 评判
│   └── safety_checker.py            # dry-run 合规专项检查
├── reset.sh                         # 全量重置
├── reset_user.sh                    # 单用户重置
└── run_benchmark.py                 # 主入口
```
