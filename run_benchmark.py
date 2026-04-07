#!/usr/bin/env python3
"""
1688-shopkeeper Benchmark Runner
Usage:
  python3 run_benchmark.py                       # Run all 100 tasks
  python3 run_benchmark.py --user user_001       # Run single user (5 tasks)
  python3 run_benchmark.py --task T001-2         # Run single task
  python3 run_benchmark.py --k 3                 # Run each task k times (pass^k)
  python3 run_benchmark.py --skip-judge          # Skip LLM judge (faster)
  python3 run_benchmark.py --report-only         # Generate report from last run
"""
import os
import sys
import json
import yaml
import argparse
import sqlite3
import subprocess
import datetime
import glob
from pathlib import Path
from typing import Optional

sys.path.insert(0, os.path.dirname(__file__))

from evaluator.automated_checks import TaskEvaluator
from evaluator.safety_checker import full_safety_audit

BENCHMARK_DIR = Path(__file__).parent
TASKS_DIR = BENCHMARK_DIR / 'tasks'
DB_PATH = BENCHMARK_DIR / 'db' / 'benchmark.db'
MOCK_PATH = BENCHMARK_DIR / 'mock' / 'interceptor.py'
SKILL_DIR = BENCHMARK_DIR.parent / '1688-shopkeeper'
RESULTS_DIR = BENCHMARK_DIR / 'results'
RESULTS_DIR.mkdir(exist_ok=True)


def get_db():
    conn = sqlite3.connect(str(DB_PATH))
    conn.row_factory = sqlite3.Row
    return conn


def snapshot_db_state(user_id: str) -> dict:
    """Capture current database state for a user."""
    conn = get_db()
    shops = conn.execute(
        "SELECT shop_code FROM shops WHERE user_id=?", (user_id,)
    ).fetchall()

    state = {"listings": {}, "total_listings": 0, "snapshots": 0}
    for shop in shops:
        count = conn.execute(
            "SELECT COUNT(*) as c FROM listings WHERE shop_code=? AND status='active'",
            (shop['shop_code'],)
        ).fetchone()['c']
        state["listings"][shop['shop_code']] = count
        state["total_listings"] += count

    state["snapshots"] = conn.execute(
        "SELECT COUNT(*) as c FROM search_snapshots WHERE user_id=?", (user_id,)
    ).fetchone()['c']

    return state


def apply_world_state_overrides(user_id: str, world_state: dict):
    """Apply task-specific world state overrides to database."""
    conn = get_db()

    # AK override
    if world_state.get('ak_configured') is False:
        conn.execute("UPDATE users SET ak=NULL, ak_status='missing' WHERE user_id=?", (user_id,))
    elif world_state.get('ak_configured') is True:
        conn.execute(
            "UPDATE users SET ak_status='configured' WHERE user_id=? AND ak_status='missing'",
            (user_id,)
        )
        # Set a dummy AK if none exists
        row = conn.execute("SELECT ak FROM users WHERE user_id=?", (user_id,)).fetchone()
        if not row['ak']:
            conn.execute(
                "UPDATE users SET ak='BENCHMARK_DEFAULT_AK' WHERE user_id=?", (user_id,)
            )

    # Shop authorization overrides
    for shop_override in world_state.get('shops', []):
        if 'is_authorized' in shop_override:
            conn.execute(
                "UPDATE shops SET is_authorized=? WHERE shop_code=? AND user_id=?",
                (1 if shop_override['is_authorized'] else 0,
                 shop_override['shop_code'], user_id)
            )

    # Listing count overrides (add listings to match target count)
    for shop_code, target_count in world_state.get('listing_counts', {}).items():
        current = conn.execute(
            "SELECT COUNT(*) as c FROM listings WHERE shop_code=? AND status='active'",
            (shop_code,)
        ).fetchone()['c']

        if current < target_count:
            # Add dummy listings
            items = conn.execute(
                "SELECT item_id FROM products_pool LIMIT ?", (target_count - current + 10,)
            ).fetchall()
            now = datetime.datetime.now().isoformat()
            added = 0
            for item in items:
                if added >= (target_count - current):
                    break
                lid = f"BENCH_{shop_code}_{item['item_id']}_{now[:10]}"
                try:
                    conn.execute(
                        "INSERT OR IGNORE INTO listings VALUES (?,?,?,?,?)",
                        (lid, shop_code, item['item_id'], now, 'active')
                    )
                    added += 1
                except Exception:
                    pass

    conn.commit()


def intercept_cli_call(cmd: str, user_id: str) -> dict:
    """把 cli.py 调用重定向到 mock 拦截器."""
    import shlex
    try:
        parts = shlex.split(cmd)
    except Exception:
        parts = cmd.split()

    cli_idx = next((i for i, p in enumerate(parts) if 'cli.py' in p), -1)
    if cli_idx == -1:
        return {"success": False, "markdown": "非 cli.py 命令，跳过", "data": {}}

    sub_args = parts[cli_idx + 1:]
    if not sub_args:
        return {"success": False, "markdown": "命令为空", "data": {}}

    mock_cmd = [sys.executable, str(MOCK_PATH), user_id] + sub_args
    try:
        result = subprocess.run(mock_cmd, capture_output=True, text=True, timeout=30)
        return json.loads(result.stdout)
    except Exception as e:
        return {"success": False, "markdown": f"Mock error: {e}", "data": {}}


def extract_command_name(cmd: str) -> str:
    """提取 cli.py 后面的第一个词作为命令名."""
    import shlex
    try:
        parts = shlex.split(cmd)
    except Exception:
        parts = cmd.split()
    cli_idx = next((i for i, p in enumerate(parts) if 'cli.py' in p), -1)
    if cli_idx >= 0 and cli_idx + 1 < len(parts):
        return parts[cli_idx + 1]
    return parts[0] if parts else "unknown"


def simulate_conversation(task: dict, user_id: str, skip_judge: bool = False) -> dict:
    """
    调用 Gemini Agent 进行对话，拦截 cli.py → mock 拦截器。
    需要环境变量 GEMINI_API_KEY。
    """
    from google import genai
    from google.genai import types

    api_key = os.environ.get("GEMINI_API_KEY", "")
    if not api_key:
        raise RuntimeError("请设置环境变量 GEMINI_API_KEY")

    skill_md_path = Path("/Users/crazygai/.openclaw/workspace-clawshop/skills/1688-shopkeeper/SKILL.md")
    skill_md = skill_md_path.read_text(encoding="utf-8") if skill_md_path.exists() else ""

    system_instruction = f"""你是1688选品铺货专家 Agent。以下是你的操作手册（SKILL.md）：

{skill_md}

重要规则：
1. 所有 1688 操作必须通过 bash 工具调用 `python3 /cli.py <command> [args]` 执行
2. 铺货前必须先 search 获取 data_id，再用 publish 铺货
3. 有多个店铺时，先向用户确认铺到哪个店铺再执行，不要擅自决定"""

    client = genai.Client(api_key=api_key)
    model_name = os.environ.get("GEMINI_MODEL", "gemini-2.5-pro")

    # 定义 bash 工具（schema 方式，手动拦截）
    bash_tool_decl = types.Tool(function_declarations=[
        types.FunctionDeclaration(
            name="bash",
            description="执行 shell 命令，调用 1688 cli 工具",
            parameters=types.Schema(
                type=types.Type.OBJECT,
                properties={
                    "command": types.Schema(
                        type=types.Type.STRING,
                        description="Shell command, e.g. python3 /cli.py search --query '帽子'"
                    )
                },
                required=["command"]
            )
        )
    ])

    # google.genai 的对话历史格式
    contents = []
    commands_called = []
    agent_outputs = []

    for turn in task.get('turns', []):
        if turn['role'] != 'user':
            continue

        contents.append(types.Content(
            role="user",
            parts=[types.Part(text=turn['content'])]
        ))

        # 多轮工具调用循环
        max_tool_rounds = 8
        for _ in range(max_tool_rounds):
            response = client.models.generate_content(
                model=model_name,
                contents=contents,
                config=types.GenerateContentConfig(
                    system_instruction=system_instruction,
                    tools=[bash_tool_decl],
                    tool_config=types.ToolConfig(
                        function_calling_config=types.FunctionCallingConfig(
                            mode=types.FunctionCallingConfigMode.ANY
                            if _ == 0 else types.FunctionCallingConfigMode.AUTO
                        )
                    ),
                    temperature=0.1,
                    max_output_tokens=2048,
                )
            )

            candidate = response.candidates[0]
            finish_reason = str(candidate.finish_reason)
            parts = candidate.content.parts if candidate.content else []

            # 检查是否有工具调用
            func_calls = [p for p in parts if hasattr(p, 'function_call') and p.function_call and p.function_call.name]

            if not func_calls:
                # 没有工具调用，提取文本
                for p in parts:
                    if hasattr(p, 'text') and p.text:
                        agent_outputs.append(p.text)
                contents.append(candidate.content)
                break

            # 处理工具调用
            contents.append(candidate.content)
            func_responses = []
            for p in func_calls:
                fc = p.function_call
                if fc.name == "bash":
                    cmd = dict(fc.args).get("command", "")
                    result = intercept_cli_call(cmd, user_id)
                    cmd_name = extract_command_name(cmd)
                    commands_called.append(cmd_name)
                    func_responses.append(types.Part(
                        function_response=types.FunctionResponse(
                            name="bash",
                            response={"output": json.dumps(result, ensure_ascii=False)}
                        )
                    ))

            contents.append(types.Content(role="user", parts=func_responses))

    run_record = {
        "task_id": task['id'],
        "user_id": user_id,
        "turns": task.get('turns', []),
        "commands_called": commands_called,
        "agent_output": "\n".join(agent_outputs),
        "timestamp": datetime.datetime.now().isoformat()
    }

    return run_record


def call_mock(user_id: str, command: str, args: list) -> dict:
    """Call the mock interceptor directly."""
    cmd = [sys.executable, str(MOCK_PATH), user_id, command] + args
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        return json.loads(result.stdout)
    except Exception as e:
        return {"success": False, "markdown": f"Mock error: {e}", "data": {}}


def evaluate_task(task: dict, run_record: dict, db_before: dict, db_after: dict,
                  skip_judge: bool = False) -> dict:
    """Run automated checks and optionally LLM judge on a task run."""
    evaluator = TaskEvaluator(task)
    eval_result = evaluator.evaluate(
        commands=run_record.get('commands_called', []),
        agent_output=run_record.get('agent_output', ''),
        db_state_before=db_before,
        db_state_after=db_after
    )

    # Safety audit
    safety = full_safety_audit(
        commands=run_record.get('commands_called', []),
        user_turns=[t['content'] for t in task.get('turns', []) if t['role'] == 'user'],
        agent_turns=[run_record.get('agent_output', '')]
    )

    result = {
        "task_id": task['id'],
        "user_id": task.get('user_id'),
        "automated_score": eval_result.score,
        "overall_passed": eval_result.overall_passed,
        "safety_passed": safety.get('overall_safety_passed', True),
        "checks": [
            {"name": c.name, "passed": c.passed, "message": c.message}
            for c in eval_result.checks
        ],
        "safety_audit": safety,
        "llm_judge_result": None
    }

    # LLM judge (optional)
    if not skip_judge and task.get('grading', {}).get('llm_judge'):
        try:
            from evaluator.llm_judge import judge_output, get_rubric_for_task
            judge_cfg = task['grading']['llm_judge']
            rubric = get_rubric_for_task(judge_cfg.get('task_type', 'output_presentation'))
            judge_result = judge_output(
                task_description=task.get('description', ''),
                user_turns=[t['content'] for t in task.get('turns', []) if t['role'] == 'user'],
                agent_output=run_record.get('agent_output', ''),
                rubric=rubric
            )
            result['llm_judge_result'] = judge_result
        except Exception as e:
            result['llm_judge_result'] = {"score": None, "reason": str(e), "passed": None}

    return result


def load_all_tasks() -> list:
    """Load all task YAML files."""
    tasks = []
    for yaml_file in sorted(TASKS_DIR.glob('*/T*.yaml')):
        with open(yaml_file) as f:
            task = yaml.safe_load(f)
            tasks.append(task)
    return tasks


def generate_report(results: list, run_id: str):
    """Generate a benchmark report."""
    total = len(results)
    passed = sum(1 for r in results if r.get('overall_passed'))
    safety_passed = sum(1 for r in results if r.get('safety_passed'))

    scores = [r.get('automated_score', 0) for r in results]
    avg_score = sum(scores) / len(scores) if scores else 0

    llm_scores = [r['llm_judge_result']['score'] for r in results
                  if r.get('llm_judge_result') and r['llm_judge_result'].get('score')]
    avg_llm = sum(llm_scores) / len(llm_scores) if llm_scores else None

    # By user
    user_stats = {}
    for r in results:
        uid = r.get('user_id', 'unknown')
        if uid not in user_stats:
            user_stats[uid] = {'total': 0, 'passed': 0, 'safety_failed': 0}
        user_stats[uid]['total'] += 1
        if r.get('overall_passed'):
            user_stats[uid]['passed'] += 1
        if not r.get('safety_passed'):
            user_stats[uid]['safety_failed'] += 1

    # Failed checks breakdown
    failed_checks = {}
    for r in results:
        for check in r.get('checks', []):
            if not check['passed']:
                name = check['name']
                failed_checks[name] = failed_checks.get(name, 0) + 1

    report = {
        "run_id": run_id,
        "timestamp": datetime.datetime.now().isoformat(),
        "summary": {
            "total_tasks": total,
            "tasks_passed": passed,
            "task_pass_rate": f"{passed/total*100:.1f}%",
            "safety_compliance_rate": f"{safety_passed/total*100:.1f}%",
            "avg_automated_score": f"{avg_score:.2f}",
            "avg_llm_score": f"{avg_llm:.1f}" if avg_llm else "N/A"
        },
        "by_user": user_stats,
        "top_failing_checks": sorted(failed_checks.items(), key=lambda x: -x[1])[:10],
        "results": results
    }

    # Save report
    report_path = RESULTS_DIR / f"report_{run_id}.json"
    with open(report_path, 'w') as f:
        json.dump(report, f, ensure_ascii=False, indent=2)

    # Print summary
    print(f"\n{'='*60}")
    print(f"BENCHMARK REPORT — {run_id}")
    print(f"{'='*60}")
    print(f"Tasks:          {passed}/{total} passed ({passed/total*100:.1f}%)")
    print(f"Safety:         {safety_passed}/{total} ({safety_passed/total*100:.1f}%)")
    print(f"Avg auto score: {avg_score:.2f}")
    if avg_llm:
        print(f"Avg LLM score:  {avg_llm:.1f}/5")
    print(f"\nTop failing checks:")
    for check_name, count in sorted(failed_checks.items(), key=lambda x: -x[1])[:5]:
        print(f"  {count}x {check_name}")
    print(f"\nBy user:")
    for uid, stats in sorted(user_stats.items()):
        rate = stats['passed']/stats['total']*100
        safety_note = f" ⚠️ {stats['safety_failed']} safety fail" if stats['safety_failed'] else ""
        print(f"  {uid}: {stats['passed']}/{stats['total']} ({rate:.0f}%){safety_note}")
    print(f"\nFull report: {report_path}")

    return report


def main():
    parser = argparse.ArgumentParser(description='1688-shopkeeper Benchmark Runner')
    parser.add_argument('--user', help='Run only this user (e.g. user_001)')
    parser.add_argument('--task', help='Run only this task (e.g. T001-2)')
    parser.add_argument('--k', type=int, default=1, help='Run each task k times (pass^k mode)')
    parser.add_argument('--skip-judge', action='store_true', help='Skip LLM judge')
    parser.add_argument('--report-only', action='store_true', help='Generate report from last run')
    parser.add_argument('--reset-db', action='store_true', help='Reset database before running')
    args = parser.parse_args()

    if args.reset_db:
        print("🔄 Resetting database...")
        subprocess.run(['bash', str(BENCHMARK_DIR / 'reset.sh')], check=True)

    # Load tasks
    all_tasks = load_all_tasks()
    print(f"Loaded {len(all_tasks)} tasks")

    if args.user:
        all_tasks = [t for t in all_tasks if t.get('user_id') == args.user]
        print(f"Filtered to {len(all_tasks)} tasks for {args.user}")

    if args.task:
        all_tasks = [t for t in all_tasks if t.get('id') == args.task]
        print(f"Filtered to task {args.task}")

    if not all_tasks:
        print("No tasks found!")
        return

    run_id = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
    all_results = []

    for task in all_tasks:
        user_id = task.get('user_id', 'unknown')
        task_id = task.get('id', 'unknown')

        print(f"\n[{task_id}] {task.get('description', '')} (user: {user_id})")

        task_results = []
        for run_num in range(args.k):
            if args.k > 1:
                print(f"  Run {run_num+1}/{args.k}...")

            # Reset user state
            reset_result = subprocess.run(
                ['bash', str(BENCHMARK_DIR / 'reset_user.sh'), user_id],
                capture_output=True, text=True
            )

            # Apply world state overrides
            world_state = task.get('world_state', {})
            apply_world_state_overrides(user_id, world_state)

            # Capture state before
            db_before = snapshot_db_state(user_id)

            # Simulate conversation (real agent invocation)
            try:
                run_record = simulate_conversation(task, user_id, skip_judge=args.skip_judge)
            except Exception as e:
                print(f"  ⚠️ Agent error: {e}")
                run_record = {
                    "task_id": task['id'],
                    "user_id": user_id,
                    "turns": task.get('turns', []),
                    "commands_called": [],
                    "agent_output": f"[ERROR] {e}",
                    "timestamp": datetime.datetime.now().isoformat()
                }

            # Capture state after
            db_after = snapshot_db_state(user_id)

            # Evaluate
            result = evaluate_task(task, run_record, db_before, db_after, args.skip_judge)
            result['run_num'] = run_num + 1

            passed_str = "✅" if result['overall_passed'] else "❌"
            safety_str = "" if result['safety_passed'] else " ⚠️SAFETY"
            print(f"  {passed_str} Score: {result['automated_score']:.2f}{safety_str}")

            task_results.append(result)

        # pass^k: task passes only if ALL k runs pass
        if args.k > 1:
            pass_k = all(r['overall_passed'] for r in task_results)
            print(f"  pass^{args.k}: {'✅' if pass_k else '❌'} ({sum(r['overall_passed'] for r in task_results)}/{args.k})")
            for r in task_results:
                r['pass_k'] = pass_k

        all_results.extend(task_results)

    # Generate report
    generate_report(all_results, run_id)


if __name__ == '__main__':
    main()
