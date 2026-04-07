"""
LLM-based judge for qualitative evaluation of agent outputs.
Uses Gemini 2.5 Pro to evaluate output quality, coherence, and correctness.
"""
import os
import json
from typing import Optional
from google import genai

JUDGE_MODEL = os.environ.get("JUDGE_MODEL", "gemini-2.5-pro")

_client = None

def _get_client():
    global _client
    if _client is None:
        api_key = os.environ.get("GEMINI_API_KEY", "")
        if not api_key:
            raise RuntimeError("请设置环境变量 GEMINI_API_KEY")
        _client = genai.Client(api_key=api_key)
    return _client


def judge_output(
    task_description: str,
    user_turns: list[str],
    agent_output: str,
    rubric: str,
    context: Optional[str] = None
) -> dict:
    """
    Ask LLM to judge agent output quality.
    Returns: {"score": 1|3|5, "reason": str, "passed": bool}
    """
    context_section = f"\n\n**Context**: {context}" if context else ""

    prompt = f"""You are evaluating the output of an AI agent that assists Chinese e-commerce shopkeepers using the 1688 platform.

**Task**: {task_description}{context_section}

**User conversation**:
{chr(10).join(f'User: {t}' for t in user_turns)}

**Agent output**:
{agent_output}

**Evaluation rubric**:
{rubric}

Score the agent output on a scale of 1, 3, or 5:
- 5: Excellent — fully meets all rubric criteria
- 3: Acceptable — meets most criteria with minor issues
- 1: Poor — fails to meet key criteria

Respond with JSON only:
{{"score": <1|3|5>, "reason": "<brief explanation>", "passed": <true if score >= 3>}}"""

    client = _get_client()
    response = client.models.generate_content(
        model=JUDGE_MODEL,
        contents=prompt,
    )

    try:
        text = response.text.strip()
        # Extract JSON
        if '```' in text:
            text = text.split('```')[1].replace('json', '').strip()
        result = json.loads(text)
        return result
    except Exception as e:
        return {"score": 1, "reason": f"Judge failed to parse response: {e}", "passed": False}


# ─────────────────────────────────────────
# Standard rubrics
# ─────────────────────────────────────────

RUBRIC_OUTPUT_PRESENTATION = """
Evaluate whether the agent correctly presented the CLI output:
- 5: Agent output the markdown field verbatim, then appended its own analysis AFTER. Analysis added value (mentioned specific metrics like sales/good_rate). Did NOT mix raw data into markdown.
- 3: Agent output markdown but analysis was slightly mixed in, or analysis was generic/vague.
- 1: Agent rewrote/summarized the markdown instead of outputting it, OR dumped raw JSON data to user.
"""

RUBRIC_PRODUCT_SELECTION_QUALITY = """
Evaluate the quality of the agent's product selection analysis:
- 5: Agent used specific metrics (月销量≥500, 好评率, 下游铺货数 blue/red ocean, 复购率) to evaluate products. Gave concrete recommendation with reasons.
- 3: Agent gave general recommendations without specific metric thresholds, or mentioned only 1-2 metrics.
- 1: Agent just listed products without analysis, or made recommendations without any metric basis.
"""

RUBRIC_ERROR_RECOVERY = """
Evaluate whether the agent correctly handled an error:
- 5: Agent output the markdown error message first, then provided the specific guidance matching the error type (AK missing → APP link, auth expired → re-authorize, rate limited → wait 1-2 min).
- 3: Agent provided guidance but incomplete or slightly off from the required guidance.
- 1: Agent ignored error, provided wrong guidance, or made user do unnecessary steps.
"""

RUBRIC_MULTI_STEP_COHERENCE = """
Evaluate whether the agent maintained logical coherence across multiple steps:
- 5: Agent maintained context across turns (used data_id from search in publish, used shop_code from shops correctly). Each step logically followed from the previous. No unnecessary repetition or wrong references.
- 3: Agent completed the flow but with some context loss or minor logical gaps.
- 1: Agent lost track of context, mixed up steps, or failed to complete the pipeline.
"""

RUBRIC_FAQ_QUALITY = """
Evaluate whether the agent answered a business knowledge question correctly:
- 5: Agent loaded the relevant FAQ/reference doc and gave specific, accurate answer based on that doc. Did not answer from general knowledge alone.
- 3: Agent gave a reasonable answer but may have missed specific details from the FAQ.
- 1: Agent answered from general knowledge without loading the reference doc, gave inaccurate or vague answer.
"""

RUBRIC_DAILY_REPORT = """
Evaluate the quality of the shop daily report presentation:
- 5: Report includes both required sections (经营状态 + 主营商品矩阵). Contains specific numbers. If no sales, uses encouraging language not templates. Markdown is properly structured.
- 3: Report has one section missing or contains generic template language for zero-sales situation.
- 1: Report is missing major sections, contains raw data dump, or is too vague to be useful.
"""

RUBRIC_NO_HALLUCINATION = """
Check whether the agent fabricated information:
- 5: All specific data (prices, sales volumes, dates, product names) in the output matches what the mock system returned. No invented metrics or false claims.
- 3: Minor inaccuracies that don't significantly mislead the user.
- 1: Agent fabricated product data, invented sales figures, or made false claims about the platform.
"""


def get_rubric_for_task(task_type: str) -> str:
    """Return the appropriate rubric for a task type."""
    rubrics = {
        'output_presentation': RUBRIC_OUTPUT_PRESENTATION,
        'product_selection': RUBRIC_PRODUCT_SELECTION_QUALITY,
        'error_recovery': RUBRIC_ERROR_RECOVERY,
        'multi_step': RUBRIC_MULTI_STEP_COHERENCE,
        'faq': RUBRIC_FAQ_QUALITY,
        'daily_report': RUBRIC_DAILY_REPORT,
        'hallucination': RUBRIC_NO_HALLUCINATION,
    }
    return rubrics.get(task_type, RUBRIC_OUTPUT_PRESENTATION)
