# 如何将 Benchmark 接入真实 Agent

## 当前状态

Benchmark 已包含：
- ✅ SQLite 数据库（20用户、27店铺、755上架记录、1624出单记录）
- ✅ 300个 mock 商品池
- ✅ 100条任务 YAML（tasks/user_001/ ~ tasks/user_020/）
- ✅ Mock 拦截器（mock/interceptor.py）—— 替代真实 1688 API
- ✅ 自动化检查器（evaluator/automated_checks.py）
- ✅ Safety 专项检查（evaluator/safety_checker.py）
- ✅ LLM Judge（evaluator/llm_judge.py，需要 ANTHROPIC_API_KEY）
- ✅ 重置脚本（reset.sh / reset_user.sh）

## 接入真实 Agent 的步骤

### 1. 让 Agent 使用 Mock 拦截器

在 Claude Code（OpenClaw）环境中，将 `python3 cli.py` 的调用重定向到 mock：

```bash
# 设置环境变量，让 skill 知道使用 mock
export BENCHMARK_USER_ID=user_006
export BENCHMARK_MOCK_PATH=/path/to/benchmark/mock/interceptor.py

# skill 中的 cli.py 调用替换为：
python3 $BENCHMARK_MOCK_PATH $BENCHMARK_USER_ID <command> [args...]
```

或者在 benchmark runner 中通过 hook 拦截所有 `python3 cli.py` 调用。

### 2. 记录 Agent 行为

在 `run_benchmark.py` 的 `simulate_conversation()` 函数中，替换为真实 Agent 调用：

```python
def simulate_conversation(task, user_id, ...):
    # 替换这个函数为真实 Agent SDK 调用
    from anthropic import Anthropic

    client = Anthropic()
    commands_called = []

    # 注入系统提示（包含 SKILL.md 内容）
    system = load_skill_md()

    messages = []
    for turn in task['turns']:
        messages.append({"role": "user", "content": turn['content']})

        # 调用 Agent
        response = client.messages.create(
            model="claude-sonnet-4-6",
            system=system,
            messages=messages,
            tools=[...],  # 工具定义
        )

        # 记录工具调用
        for block in response.content:
            if block.type == "tool_use" and block.name == "Bash":
                commands_called.append(block.input.get("command", ""))

        messages.append({"role": "assistant", "content": response.content})

    return {
        "commands_called": commands_called,
        "agent_output": extract_text_output(response),
        ...
    }
```

### 3. 运行 Benchmark

```bash
# 安装依赖
pip install -r requirements.txt

# 重置数据库
bash reset.sh

# 运行全部 100 个任务
python3 run_benchmark.py

# 运行单个用户
python3 run_benchmark.py --user user_006

# pass^3 可靠性测试
python3 run_benchmark.py --k 3

# 跳过 LLM judge（快速模式）
python3 run_benchmark.py --skip-judge

# 需要 ANTHROPIC_API_KEY 用于 LLM judge
export ANTHROPIC_API_KEY=your_key
```

### 4. 快速验证 Mock 拦截器

```bash
# 直接测试各命令
python3 mock/interceptor.py user_006 search --query "帽子"
python3 mock/interceptor.py user_006 shop_daily
python3 mock/interceptor.py user_001 search --query "帽子"  # AK未配置，应返回错误
python3 mock/interceptor.py user_017 shops                   # 全部授权过期

# 重置单个用户
bash reset_user.sh user_006
```

## 关键设计决策

| 决策 | 原因 |
|------|------|
| SQLite（非内存数据库）| 支持重置后验证状态变化，跨进程可访问 |
| Mock 拦截 cli.py | 与真实1688 API解耦，测试可重复 |
| 每个 Task 重置用户状态 | 避免任务间干扰，保证独立性 |
| world_state 覆盖 | 支持测试"授权恢复后"等状态，无需手动操作 |
| pass^k | 检测不稳定行为，部署决策基于可靠性 |
