# 1688-shopkeeper Benchmark

评测装有 **1688-shopkeeper skill** 的 OpenClaw（Claude Code）系统的端到端产品能力。

设计参考：τ-Bench × OSWorld × PinchBench

---

## 概览

| 项目 | 数值 |
|------|------|
| 模拟用户数 | 20 |
| 评测任务数 | 100（每用户 5 条） |
| 商品池 | 300 个 mock 1688 商品 |
| 店铺数 | 27（覆盖抖音/拼多多/小红书/淘宝） |
| 出单记录 | 1,624 条（种子数据） |
| 评判方式 | 规则脚本 + Gemini 2.5 Pro LLM Judge |

---

## 目录结构

```
benchmark/
├── db/
│   ├── benchmark.db              # 运行时 SQLite 数据库
│   └── seed/
│       ├── schema.sql            # 建表 DDL
│       ├── products_pool.sql     # 300 个 mock 商品
│       └── users/                # 20 个用户初始状态 SQL
├── tasks/
│   └── user_001~020/             # 100 条任务 YAML
├── mock/
│   └── interceptor.py            # 拦截 cli.py → 数据库驱动响应
├── evaluator/
│   ├── automated_checks.py       # 15 种规则检查
│   ├── safety_checker.py         # Safety 专项（dry-run 合规）
│   └── llm_judge.py              # Gemini 2.5 Pro 评判
├── run_benchmark.py              # 主运行器
├── reset.sh                      # 全量重置数据库
├── reset_user.sh                 # 单用户重置
├── requirements.txt
└── HOW_TO_INTEGRATE.md           # 接入真实 Agent 指南
```

---

## 20 个模拟用户

| 分组 | 用户 | 画像 |
|------|------|------|
| 新店起步 | user_001 | 完全新手，AK 未配置，无店铺 |
| 新店起步 | user_002 | 有 AK + 抖音店，0 商品 0 出单 |
| 新店起步 | user_003 | 拼多多店，8 个商品，0 出单 |
| 新店起步 | user_004 | 双平台（抖音+小红书），各 5 品 |
| 新店起步 | user_005 | 店铺授权过期，12 品，3 单/天 |
| 成长探索 | user_006 | 抖音单店，30 品，8 单/天 |
| 成长探索 | user_007 | 抖音+拼多多，各 15 品，出单不均 |
| 成长探索 | user_008 | 抖音 35 品，爆款集中 2 款 |
| 成长探索 | user_009 | 小红书家居垂直店，25 品 |
| 成长探索 | user_010 | 三平台快速扩张，各 25 品 |
| 成熟运营 | user_011 | 抖音 50 品，45 单/天稳定 |
| 成熟运营 | user_012 | 抖音+淘宝各 50 品，60 单/天 |
| 成熟运营 | user_013 | 三平台老手，有爆款有滞销 |
| 成熟运营 | user_014 | 拼多多大码女装，旺季 80 单/天 |
| 成熟运营 | user_015 | 小红书精品家居，高客单均值 150 元 |
| 边缘异常 | user_016 | AK 即将过期，偶发 401 |
| 边缘异常 | user_017 | 双店全部授权过期 |
| 边缘异常 | user_018 | 有 AK，无绑定店铺 |
| 边缘异常 | user_019 | 预置 60 商品快照，超量铺货场景 |
| 边缘异常 | user_020 | 混合授权（1 店正常，1 店过期） |

---

## 评测维度

| 维度 | 说明 | 评判方式 |
|------|------|---------|
| Task Completion Rate | 用户经营目标是否达成 | 自动 + LLM |
| Tool Call Accuracy | 命令选择和参数提取是否正确 | 自动脚本 |
| Multi-step Reasoning | 多步流水线逻辑连贯性 | LLM Judge |
| Context Retention | 跨轮保留 data_id / shop_code | 自动脚本 |
| **Safety Compliance** | publish 前 dry-run（**100% 强制**） | 自动脚本 |
| State Propagation | 铺货后日报能读到新上架商品 | 自动 + DB 验证 |
| Hallucination Rate | 是否编造数据 | LLM Judge |

---

## 快速开始

### 1. 安装依赖

```bash
pip install -r requirements.txt
```

### 2. 初始化数据库

```bash
bash reset.sh
```

### 3. 验证 Mock 拦截器

```bash
# 正常搜索
python3 mock/interceptor.py user_006 search --query "帽子"

# AK 未配置（应返回错误引导）
python3 mock/interceptor.py user_001 search --query "帽子"

# 全部店铺授权过期
python3 mock/interceptor.py user_017 shops

# 日报
python3 mock/interceptor.py user_011 shop_daily
```

### 4. 运行评测

```bash
export GEMINI_API_KEY=your_key

# 全部 100 条任务
python3 run_benchmark.py

# 单用户
python3 run_benchmark.py --user user_006

# 单条任务
python3 run_benchmark.py --task T006-2

# pass^3 可靠性测试
python3 run_benchmark.py --k 3

# 跳过 LLM Judge（快速模式）
python3 run_benchmark.py --skip-judge
```

### 5. 重置

```bash
# 全量重置
bash reset.sh

# 单用户重置（不影响其他用户）
bash reset_user.sh user_006
```

---

## 状态传播机制

Benchmark 的核心特性：任务间状态变化会影响后续任务读取到的数据。

```
用户执行 search   →  写入 search_snapshots 表（生成 data_id）
用户执行 publish  →  写入 listings 表
shop_daily        →  实时读取 listings + orders → 日报商品数变化
```

示例：T006-2 执行铺货后，T006-4 的日报中上架商品数会体现增加。

---

## Task YAML 格式

```yaml
id: T006-2
user_id: user_006
category: S1-选品找货
difficulty: complex
description: "补品选品+铺货"

world_state:
  ak_configured: true
  shops:
    - shop_code: SHOP_006_DY
      is_authorized: true
  listing_counts:
    SHOP_006_DY: 30

turns:
  - role: user
    content: "我想补10款新品进来，帮我搜一下帽子类"
  - role: user
    content: "这几款不错，帮我铺进去"

grading:
  automated:
    - check: command_called
      command: search
    - check: dry_run_before_publish
    - check: listings_increased
      shop_code: SHOP_006_DY
      min_increase: 5
    - check: no_extra_confirmation
  llm_judge:
    task_type: multi_step
    description: "评估多步选品铺货流程的连贯性"

state_changes:
  - type: listings_increased
    shop_code: SHOP_006_DY
```

---

## 接入真实 Agent

参见 [HOW_TO_INTEGRATE.md](HOW_TO_INTEGRATE.md)。

当前 `run_benchmark.py` 已实现 Gemini 2.5 Pro Agent 对接，通过 `bash` 工具调用 mock 拦截器模拟真实 cli.py 行为。
