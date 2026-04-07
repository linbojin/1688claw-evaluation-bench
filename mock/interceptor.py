"""
Mock interceptor for 1688-shopkeeper CLI.
Usage: python3 interceptor.py <user_id> <command> [args...]

Replaces real cli.py calls with database-backed responses.
"""
import sys
import json
import sqlite3
import os
import re
import argparse
import datetime
import random
import string
import hashlib

DB_PATH = os.path.join(os.path.dirname(__file__), '..', 'db', 'benchmark.db')


def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def make_output(success, markdown, data=None):
    return json.dumps({
        "success": success,
        "markdown": markdown,
        "data": data or {}
    }, ensure_ascii=False)


def make_error(code, message, data=None):
    return make_output(False, message, data)


def gen_data_id():
    now = datetime.datetime.now()
    rand = ''.join(random.choices(string.digits, k=3))
    return now.strftime('%Y%m%d_%H%M%S_') + rand


def check_ak(user_id, conn):
    row = conn.execute("SELECT ak, ak_status FROM users WHERE user_id=?", (user_id,)).fetchone()
    if not row:
        return False, make_error('USER_NOT_FOUND', f'用户 {user_id} 不存在')
    if row['ak_status'] == 'missing' or not row['ak']:
        return False, make_error('AK_NOT_CONFIGURED',
            '## AK 未配置\n\n请先配置您的1688 AK才能使用此功能。')
    if row['ak_status'] == 'expiring':
        # 50% chance of 401 for expiring AK
        if random.random() < 0.5:
            return False, make_error('AUTH_INVALID',
                '## 签名无效 (401)\n\nAK 即将过期，请重新获取AK并配置。')
    return True, None


# ─────────────────────────────────────────
# Command handlers
# ─────────────────────────────────────────

def cmd_configure(user_id, args):
    parser = argparse.ArgumentParser()
    parser.add_argument('ak', nargs='?')
    parsed, _ = parser.parse_known_args(args)

    conn = get_db()
    if not parsed.ak:
        row = conn.execute("SELECT ak_status FROM users WHERE user_id=?", (user_id,)).fetchone()
        if row and row['ak_status'] == 'configured':
            return make_output(True, '## 配置状态\n\nAK 已配置，状态正常。')
        return make_output(False, '## AK 未配置\n\n请提供AK参数。')

    conn.execute("UPDATE users SET ak=?, ak_status='configured' WHERE user_id=?",
                 (parsed.ak, user_id))
    conn.commit()
    return make_output(True, f'## 配置成功\n\nAK 已配置完成，您现在可以使用所有功能了。')


def cmd_check(user_id, args):
    conn = get_db()
    row = conn.execute("SELECT ak, ak_status FROM users WHERE user_id=?", (user_id,)).fetchone()
    if not row or row['ak_status'] == 'missing':
        return make_output(False, '## AK 未配置\n\n请先配置您的1688 AK。')
    return make_output(True, f'## 配置检查通过\n\n- AK状态: {row["ak_status"]}\n- 所有功能可用')


def cmd_shops(user_id, args):
    ok, err = check_ak(user_id, get_db())
    if not ok:
        return err

    conn = get_db()
    rows = conn.execute(
        "SELECT shop_code, name, channel, is_authorized, auth_expires_at FROM shops WHERE user_id=?",
        (user_id,)
    ).fetchall()

    total = len(rows)
    valid = sum(1 for r in rows if r['is_authorized'])
    expired = total - valid

    if total == 0:
        return make_output(False, '## 店铺未绑定\n\n您还没有绑定任何下游店铺。',
                           {"total": 0, "valid_count": 0, "expired_count": 0, "shops": []})

    shops_data = [dict(r) for r in rows]

    lines = ['## 我的绑定店铺\n']
    lines.append(f'共绑定 **{total}** 个店铺，其中 **{valid}** 个授权有效，**{expired}** 个已过期。\n')
    lines.append('| 店铺名称 | 平台 | 授权状态 | 店铺编码 |')
    lines.append('|---------|------|---------|---------|')
    for s in shops_data:
        status = '✅ 有效' if s['is_authorized'] else '❌ 已过期'
        channel_names = {'douyin': '抖音', 'pinduoduo': '拼多多', 'xiaohongshu': '小红书', 'taobao': '淘宝'}
        ch = channel_names.get(s['channel'], s['channel'])
        lines.append(f'| {s["name"]} | {ch} | {status} | {s["shop_code"]} |')

    return make_output(True, '\n'.join(lines), {
        "total": total,
        "valid_count": valid,
        "expired_count": expired,
        "shops": shops_data
    })


def cmd_search(user_id, args):
    ok, err = check_ak(user_id, get_db())
    if not ok:
        return err

    parser = argparse.ArgumentParser()
    parser.add_argument('--query', required=True)
    parser.add_argument('--channel', default=None)
    try:
        parsed, _ = parser.parse_known_args(args)
    except SystemExit:
        return make_error('PARAM_ERROR', '## 参数错误\n\n请提供 --query 参数。')

    conn = get_db()
    query = parsed.query.lower()

    # 关键词映射到类目
    category_keywords = {
        '帽': '帽子', 'hat': '帽子', '遮阳': '帽子', '棒球帽': '帽子',
        '露营': '露营', '户外': '露营', '折叠椅': '露营', '帐篷': '露营',
        '大码': '大码女装', '胖mm': '大码女装',
        '家居': '家居', '台灯': '家居', '收纳': '家居', '花瓶': '家居',
        '手机壳': '手机配件', '数据线': '手机配件', '充电': '手机配件',
        '女装': '女装', '连衣裙': '女装', '卫衣': '女装',
        '厨房': '厨房', '炒锅': '厨房', '保鲜': '厨房',
        '运动': '运动健身', '瑜伽': '运动健身', '健身': '运动健身',
        '美妆': '美妆', '护肤': '美妆', '口红': '美妆',
        '玩具': '儿童', '儿童': '儿童', '积木': '儿童',
        '礼品': '礼品', '礼盒': '礼品', '礼物': '礼品',
        '宠物': '宠物', '猫': '宠物', '狗': '宠物',
        '文具': '文具', '笔': '文具',
    }

    matched_category = None
    for kw, cat in category_keywords.items():
        if kw in query:
            matched_category = cat
            break

    if matched_category:
        rows = conn.execute(
            "SELECT * FROM products_pool WHERE category=? ORDER BY last30DaysSales DESC LIMIT 20",
            (matched_category,)
        ).fetchall()
    else:
        rows = conn.execute(
            "SELECT * FROM products_pool ORDER BY last30DaysSales DESC LIMIT 20"
        ).fetchall()

    if not rows:
        return make_output(True,
            f'## 搜索结果\n\n关键词「{parsed.query}」未找到相关商品，建议换用更宽泛的关键词。',
            {"product_count": 0, "data_id": None, "products": []})

    data_id = gen_data_id()
    products = [dict(r) for r in rows]
    product_ids = [p['item_id'] for p in products]

    # 保存快照到数据库
    conn.execute(
        "INSERT OR REPLACE INTO search_snapshots VALUES (?,?,?,?,?,?)",
        (data_id, user_id, parsed.query, parsed.channel,
         datetime.datetime.now().isoformat(), json.dumps(product_ids))
    )
    conn.commit()

    # 生成 markdown
    channel_names = {'douyin': '抖音', 'pinduoduo': '拼多多', 'xiaohongshu': '小红书', 'taobao': '淘宝'}
    ch_name = channel_names.get(parsed.channel, parsed.channel or '全平台')

    lines = [f'## 搜索结果：{parsed.query}（{ch_name}）\n']
    lines.append(f'找到 **{len(products)}** 款商品，数据快照 ID：`{data_id}`\n')
    lines.append('| # | 商品名称 | 价格 | 月销量 | 好评率 | 下游铺货数 | 商品ID |')
    lines.append('|---|---------|------|-------|-------|-----------|-------|')
    for i, p in enumerate(products[:15], 1):
        good_rate = f"{p['goodRates']*100:.0f}%"
        flag = '⚠️' if p['downstreamOffer'] > 500 else ('🔵' if p['downstreamOffer'] < 200 else '')
        lines.append(f'| {i} | {p["title"][:20]} | ¥{p["price"]} | {p["last30DaysSales"]} | {good_rate} | {p["downstreamOffer"]}{flag} | {p["item_id"]} |')

    return make_output(True, '\n'.join(lines), {
        "data_id": data_id,
        "product_count": len(products),
        "products": products
    })


def cmd_prod_detail(user_id, args):
    ok, err = check_ak(user_id, get_db())
    if not ok:
        return err

    parser = argparse.ArgumentParser()
    parser.add_argument('--item-ids', dest='item_ids', default=None)
    parser.add_argument('--data-id', dest='data_id', default=None)
    parsed, _ = parser.parse_known_args(args)

    conn = get_db()

    item_ids = []
    if parsed.item_ids:
        item_ids = [x.strip() for x in parsed.item_ids.split(',')]
    elif parsed.data_id:
        snap = conn.execute(
            "SELECT product_ids FROM search_snapshots WHERE data_id=? AND user_id=?",
            (parsed.data_id, user_id)
        ).fetchone()
        if not snap:
            return make_error('SNAPSHOT_NOT_FOUND', f'## 快照不存在\n\n未找到 data_id={parsed.data_id}')
        item_ids = json.loads(snap['product_ids'])[:5]  # 限制前5个

    if not item_ids:
        return make_error('PARAM_ERROR', '## 参数错误\n\n请提供 --item-ids 或 --data-id')

    rows = conn.execute(
        f"SELECT * FROM products_pool WHERE item_id IN ({','.join('?'*len(item_ids))})",
        item_ids
    ).fetchall()

    data_id = parsed.data_id or gen_data_id()
    details = {}
    for r in rows:
        details[r['item_id']] = {
            "all_info": f"""## {r['title']}

**价格**: ¥{r['price']}
**类目**: {r['category']}
**商家**: {r['merchant_name']} ({r['merchant_type']})
**月销量**: {r['last30DaysSales']} 件
**好评率**: {r['goodRates']*100:.1f}%
**复购率**: {r['repurchaseRate']*100:.1f}%
**下游铺货数**: {r['downstreamOffer']}
**评价数**: {r['remarkCnt']}

**SKU属性**: 颜色（黑色/白色/蓝色）、尺码（M/L/XL）
**CPV属性**: 品牌（无品牌）、产地（国产）、材质（根据类目）
"""
        }

    lines = [f'## 商品详情（{len(rows)} 件）\n']
    for item_id, detail in details.items():
        lines.append(detail['all_info'])
        lines.append('---')

    return make_output(True, '\n'.join(lines), {
        "data_id": data_id,
        "detail_count": len(rows),
        "details": details
    })


def cmd_publish(user_id, args):
    ok, err = check_ak(user_id, get_db())
    if not ok:
        return err

    parser = argparse.ArgumentParser()
    parser.add_argument('--shop-code', dest='shop_code', default=None)
    parser.add_argument('--data-id', dest='data_id', default=None)
    parser.add_argument('--item-ids', dest='item_ids', default=None)
    parser.add_argument('--dry-run', dest='dry_run', action='store_true', default=False)
    parsed, _ = parser.parse_known_args(args)

    conn = get_db()

    # 获取商品列表
    item_ids = []
    if parsed.item_ids:
        item_ids = [x.strip() for x in parsed.item_ids.split(',')]
    elif parsed.data_id:
        snap = conn.execute(
            "SELECT product_ids FROM search_snapshots WHERE data_id=? AND user_id=?",
            (parsed.data_id, user_id)
        ).fetchone()
        if not snap:
            return make_error('SNAPSHOT_NOT_FOUND', f'## 快照不存在\n\n未找到 data_id={parsed.data_id}')
        item_ids = json.loads(snap['product_ids'])

    if not item_ids:
        return make_error('PARAM_ERROR', '## 参数错误\n\n请提供 --data-id 或 --item-ids')

    origin_count = len(item_ids)
    item_ids = item_ids[:20]  # 最多20条

    # 确认目标店铺
    shops = conn.execute(
        "SELECT shop_code, name, channel, is_authorized FROM shops WHERE user_id=?", (user_id,)
    ).fetchall()
    valid_shops = [s for s in shops if s['is_authorized']]

    if not shops:
        return make_error('NO_SHOPS', '## 店铺未绑定\n\n您还没有绑定任何下游店铺。')

    # 目标店铺歧义处理
    target_shop = None
    if parsed.shop_code:
        for s in shops:
            if s['shop_code'] == parsed.shop_code:
                target_shop = s
                break
        if not target_shop:
            return make_error('SHOP_NOT_FOUND', f'## 店铺不存在\n\n未找到 shop_code={parsed.shop_code}')
    elif len(valid_shops) == 1:
        target_shop = valid_shops[0]
    elif len(valid_shops) == 0:
        return make_error('AUTH_EXPIRED',
            '## 授权过期 (511)\n\n所有店铺的授权已过期，请前往1688 AI版APP重新授权。',
            {"error_code": "511"})
    else:
        # 多个有效店铺，需要追问
        shop_list = ', '.join(f'{s["name"]}({s["channel"]})' for s in valid_shops)
        return make_output(True,
            f'## 需要确认铺货目标\n\n您有多个可用店铺，请告诉我要铺到哪个：\n\n{shop_list}',
            {
                "dry_run": parsed.dry_run,
                "risk_level": "write",
                "confirm_prompt": f"请问要铺到哪个店铺？可选：{shop_list}",
                "origin_count": origin_count,
                "submitted_count": 0,
                "error_code": ""
            })

    # 检查目标店铺授权
    if not target_shop['is_authorized']:
        return make_error('AUTH_EXPIRED',
            f'## 授权过期 (511)\n\n店铺「{target_shop["name"]}」的授权已过期，请重新授权后再铺货。',
            {"error_code": "511"})

    channel_names = {'douyin': '抖音', 'pinduoduo': '拼多多', 'xiaohongshu': '小红书', 'taobao': '淘宝'}
    ch_name = channel_names.get(target_shop['channel'], target_shop['channel'])

    if parsed.dry_run:
        # Dry-run: 只预检，不写入
        truncated_note = f'\n\n> ⚠️ 原始商品 {origin_count} 件，超出限制（20件/次），本次将提交前 20 件。' if origin_count > 20 else ''
        return make_output(True,
            f'## 铺货预检通过\n\n- 目标店铺：{target_shop["name"]}（{ch_name}）\n- 待铺商品：{len(item_ids)} 件{truncated_note}\n\n预检通过，可执行正式铺货。',
            {
                "dry_run": True,
                "risk_level": "write",
                "shop_code": target_shop['shop_code'],
                "origin_count": origin_count,
                "submitted_count": len(item_ids),
                "error_code": ""
            })

    # 正式铺货：写入数据库
    now = datetime.datetime.now().isoformat()
    inserted = 0
    for item_id in item_ids:
        listing_id = f"LST_{user_id.split('_')[1]}_{item_id}_{now[:10].replace('-','')}"
        try:
            conn.execute(
                "INSERT OR IGNORE INTO listings VALUES (?,?,?,?,?)",
                (listing_id, target_shop['shop_code'], item_id, now, 'active')
            )
            inserted += 1
        except Exception:
            pass
    conn.commit()

    truncated_note = f'\n\n> ⚠️ 原始商品 {origin_count} 件，本次提交前 20 件，剩余 {origin_count-20} 件请下次提交。' if origin_count > 20 else ''

    return make_output(True,
        f'## 铺货成功\n\n- 目标店铺：{target_shop["name"]}（{ch_name}）\n- 成功铺货：{inserted} 件{truncated_note}\n\n商品已提交审核，请前往平台查看上架状态。',
        {
            "dry_run": False,
            "risk_level": "write",
            "shop_code": target_shop['shop_code'],
            "origin_count": origin_count,
            "submitted_count": inserted,
            "error_code": ""
        })


def cmd_opportunities(user_id, args):
    ok, err = check_ak(user_id, get_db())
    if not ok:
        return err

    # 从商品池中选高销量商品作为热榜
    conn = get_db()
    hot_items = conn.execute(
        "SELECT * FROM products_pool ORDER BY last30DaysSales DESC LIMIT 30"
    ).fetchall()

    # 构造商机数据
    douyin_hot = [dict(r) for r in hot_items[:5]]
    taobao_hot = [dict(r) for r in hot_items[5:10]]
    xhs_hot = [dict(r) for r in hot_items[10:15]]

    lines = ['## 商机热榜（实时）\n']
    lines.append('### 🔥 抖音热榜\n')
    for i, p in enumerate(douyin_hot, 1):
        lines.append(f'{i}. **{p["title"][:25]}** | 月销 {p["last30DaysSales"]} | ¥{p["price"]}')

    lines.append('\n### 🛍️ 淘宝热榜\n')
    for i, p in enumerate(taobao_hot, 1):
        lines.append(f'{i}. **{p["title"][:25]}** | 月销 {p["last30DaysSales"]} | ¥{p["price"]}')

    lines.append('\n### 📱 小红书热榜\n')
    for i, p in enumerate(xhs_hot, 1):
        lines.append(f'{i}. **{p["title"][:25]}** | 月销 {p["last30DaysSales"]} | ¥{p["price"]}')

    return make_output(True, '\n'.join(lines), {
        "bizData": {
            "douyin": {"hot": douyin_hot},
            "taobao": {"hot": taobao_hot},
            "xiaohongshu": {"hot": xhs_hot}
        }
    })


def cmd_trend(user_id, args):
    ok, err = check_ak(user_id, get_db())
    if not ok:
        return err

    parser = argparse.ArgumentParser()
    parser.add_argument('--query', required=True)
    try:
        parsed, _ = parser.parse_known_args(args)
    except SystemExit:
        return make_error('PARAM_ERROR', '## 参数错误\n\n请提供 --query 参数。')

    conn = get_db()
    query = parsed.query.lower()

    category_keywords = {
        '帽': '帽子', '露营': '露营', '大码': '大码女装',
        '家居': '家居', '手机': '手机配件', '女装': '女装',
        '厨房': '厨房', '运动': '运动健身', '美妆': '美妆',
        '玩具': '儿童', '宠物': '宠物', '文具': '文具',
    }

    matched_cat = None
    for kw, cat in category_keywords.items():
        if kw in query:
            matched_cat = cat
            break

    if not matched_cat:
        return make_output(True,
            f'## 趋势分析：{parsed.query}\n\n未找到「{parsed.query}」的相关趋势数据，建议换用更宽泛的关键词（如：帽子、女装、家居等）。',
            {"bizData": ""})

    rows = conn.execute(
        "SELECT * FROM products_pool WHERE category=? ORDER BY last30DaysSales DESC LIMIT 20",
        (matched_cat,)
    ).fetchall()

    prices = [r['price'] for r in rows]
    avg_price = sum(prices) / len(prices) if prices else 0
    min_price = min(prices) if prices else 0
    max_price = max(prices) if prices else 0

    # 价格区间分布
    low = sum(1 for p in prices if p < avg_price * 0.7)
    mid = sum(1 for p in prices if avg_price * 0.7 <= p <= avg_price * 1.3)
    high = sum(1 for p in prices if p > avg_price * 1.3)

    top5 = [dict(r) for r in rows[:5]]

    biz_data = f"""## {parsed.query} 趋势洞察

### 📈 市场概况
- 活跃商品数：{len(rows)} 款
- 平均月销量：{int(sum(r['last30DaysSales'] for r in rows)/len(rows))} 件
- 平均好评率：{sum(r['goodRates'] for r in rows)/len(rows)*100:.1f}%

### 💰 价格分布
- 价格区间：¥{min_price:.0f} ~ ¥{max_price:.0f}
- 均价：¥{avg_price:.1f}
- 低价段（<¥{avg_price*0.7:.0f}）：{low} 款
- 中价段（¥{avg_price*0.7:.0f}~¥{avg_price*1.3:.0f}）：{mid} 款
- 高价段（>¥{avg_price*1.3:.0f}）：{high} 款

### 🏆 热销榜 Top5
"""
    for i, p in enumerate(top5, 1):
        biz_data += f'\n{i}. {p["title"][:30]} | ¥{p["price"]} | 月销{p["last30DaysSales"]}'

    return make_output(True, biz_data, {"bizData": biz_data, "category": matched_cat})


def cmd_shop_daily(user_id, args):
    ok, err = check_ak(user_id, get_db())
    if not ok:
        return err

    conn = get_db()
    shops = conn.execute(
        "SELECT shop_code, name, channel, is_authorized FROM shops WHERE user_id=?", (user_id,)
    ).fetchall()

    if not shops:
        return make_output(False,
            '## 店铺经营日报\n\n您还没有绑定店铺，暂无经营数据。',
            {"bizData": ""})

    # 汇总所有店铺数据
    total_listings = 0
    total_orders_today = 0
    total_revenue_today = 0
    shop_details = []

    today = datetime.date.today().isoformat()
    yesterday = (datetime.date.today() - datetime.timedelta(days=1)).isoformat()

    for shop in shops:
        listing_count = conn.execute(
            "SELECT COUNT(*) as cnt FROM listings WHERE shop_code=? AND status='active'",
            (shop['shop_code'],)
        ).fetchone()['cnt']

        orders_today = conn.execute(
            "SELECT COUNT(*) as cnt, COALESCE(SUM(revenue),0) as rev FROM orders WHERE shop_code=? AND order_date=?",
            (shop['shop_code'], yesterday)  # 昨天的出单
        ).fetchone()

        orders_7d = conn.execute(
            "SELECT COUNT(*) as cnt, COALESCE(SUM(revenue),0) as rev FROM orders WHERE shop_code=? AND order_date >= ?",
            (shop['shop_code'], (datetime.date.today() - datetime.timedelta(days=7)).isoformat())
        ).fetchone()

        # 热销商品
        top_items = conn.execute("""
            SELECT o.item_id, p.title, p.category, COUNT(*) as order_cnt, SUM(o.revenue) as total_rev
            FROM orders o
            JOIN products_pool p ON o.item_id = p.item_id
            WHERE o.shop_code=? AND o.order_date >= ?
            GROUP BY o.item_id
            ORDER BY order_cnt DESC
            LIMIT 5
        """, (shop['shop_code'], (datetime.date.today() - datetime.timedelta(days=7)).isoformat())).fetchall()

        # 滞销商品（上架但7天内没有出单）
        slow_items = conn.execute("""
            SELECT l.item_id, p.title, p.category
            FROM listings l
            JOIN products_pool p ON l.item_id = p.item_id
            LEFT JOIN orders o ON o.item_id = l.item_id AND o.shop_code = l.shop_code
                AND o.order_date >= ?
            WHERE l.shop_code=? AND l.status='active'
            GROUP BY l.item_id
            HAVING COUNT(o.order_id) = 0
            LIMIT 5
        """, ((datetime.date.today() - datetime.timedelta(days=7)).isoformat(), shop['shop_code'])).fetchall()

        total_listings += listing_count
        total_orders_today += orders_today['cnt']
        total_revenue_today += orders_today['rev']

        channel_names = {'douyin': '抖音', 'pinduoduo': '拼多多', 'xiaohongshu': '小红书', 'taobao': '淘宝'}

        shop_details.append({
            "shop_code": shop['shop_code'],
            "name": shop['name'],
            "channel": channel_names.get(shop['channel'], shop['channel']),
            "is_authorized": shop['is_authorized'],
            "listing_count": listing_count,
            "orders_yesterday": orders_today['cnt'],
            "revenue_yesterday": round(orders_today['rev'], 2),
            "orders_7d": orders_7d['cnt'],
            "revenue_7d": round(orders_7d['rev'], 2),
            "top_items": [dict(r) for r in top_items],
            "slow_items": [dict(r) for r in slow_items]
        })

    # 生成日报 markdown
    lines = ['## 店铺经营日报\n']

    # 一、经营状态
    lines.append('### 一、店铺经营状态\n')

    for sd in shop_details:
        auth_note = '' if sd['is_authorized'] else '⚠️ **授权已过期**'
        lines.append(f'#### {sd["name"]}（{sd["channel"]}）{auth_note}\n')
        lines.append(f'- 在售商品：**{sd["listing_count"]}** 件')
        lines.append(f'- 昨日出单：**{sd["orders_yesterday"]}** 单 | 昨日GMV：**¥{sd["revenue_yesterday"]:.0f}**')
        lines.append(f'- 近7日出单：**{sd["orders_7d"]}** 单 | 近7日GMV：**¥{sd["revenue_7d"]:.0f}**\n')

        if sd['top_items']:
            lines.append('**动销商品（近7日）**\n')
            lines.append('| 商品 | 类目 | 出单量 | 销售额 |')
            lines.append('|-----|------|-------|-------|')
            for item in sd['top_items']:
                lines.append(f'| {item["title"][:20]} | {item["category"]} | {item["order_cnt"]} | ¥{item["total_rev"]:.0f} |')
            lines.append('')
        elif sd['listing_count'] > 0:
            lines.append('> 近7日暂无出单，建议检查选品或调整定价策略。\n')
        else:
            lines.append('> 还没有上架商品，建议先选品铺货。\n')

        if sd['slow_items']:
            lines.append(f'**滞销商品（近7日0出单，共{len(sd["slow_items"])}款）**\n')
            for item in sd['slow_items'][:3]:
                lines.append(f'- {item["title"][:30]}（{item["category"]}）')
            lines.append('')

    # 二、主营商品选品矩阵
    lines.append('\n### 二、主营商品矩阵\n')
    all_categories = set()
    for sd in shop_details:
        for item in sd['top_items']:
            all_categories.add(item['category'])

    lines.append('| 主营类目 | 市场评估 | 用户建议 |')
    lines.append('|---------|---------|---------|')

    if all_categories:
        for cat in list(all_categories)[:5]:
            lines.append(f'| {cat} | 📈 动销良好 | 持续补货，关注竞品 |')
    else:
        lines.append('| 暂无动销类目 | 待观察 | 建议先铺货再观察 |')

    return make_output(True, '\n'.join(lines), {
        "bizData": '\n'.join(lines),
        "raw": {
            "total_listings": total_listings,
            "shop_details": shop_details
        },
        "analysis_payload": {
            "mode": "normal",
            "input_text": '\n'.join(lines),
            "oppo_text": "见商机热榜"
        }
    })


# ─────────────────────────────────────────
# Main dispatcher
# ─────────────────────────────────────────

COMMANDS = {
    'configure': cmd_configure,
    'check': cmd_check,
    'shops': cmd_shops,
    'search': cmd_search,
    'prod_detail': cmd_prod_detail,
    'publish': cmd_publish,
    'opportunities': cmd_opportunities,
    'trend': cmd_trend,
    'shop_daily': cmd_shop_daily,
}


def main():
    if len(sys.argv) < 3:
        print(make_error('USAGE', 'Usage: interceptor.py <user_id> <command> [args...]'))
        sys.exit(1)

    user_id = sys.argv[1]
    command = sys.argv[2]
    args = sys.argv[3:]

    if command not in COMMANDS:
        print(make_error('UNKNOWN_COMMAND', f'## 未知命令\n\n不支持的命令: {command}'))
        sys.exit(1)

    try:
        result = COMMANDS[command](user_id, args)
        print(result)
    except Exception as e:
        print(make_error('INTERNAL_ERROR', f'## 系统错误\n\n{str(e)}'))
        sys.exit(1)


if __name__ == '__main__':
    main()
