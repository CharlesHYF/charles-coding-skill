#!/usr/bin/env bash
# check.sh 回归测试
# 创建日期：2026-08-31
# 修改日期：2026-09-24

set -uo pipefail

# 被测脚本：模板里的规范校验器
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECK_SH="${REPO_ROOT}/tools/check.sh"

if [ ! -f "${CHECK_SH}" ]; then
	echo "[FATAL] 找不到被测脚本: ${CHECK_SH}"
	exit 1
fi

PASS_COUNT=0
FAIL_COUNT=0

pass() {
	local label="$1"

	echo "  [PASS] ${label}"
	PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
	local label="$1"

	echo "  [FAIL] ${label}"
	FAIL_COUNT=$((FAIL_COUNT + 1))
}

# 断言输出包含指定子串
expect_contains() {
	local output="$1"
	local needle="$2"
	local label="$3"

	if printf '%s' "${output}" | grep -qF -- "${needle}"; then
		pass "${label}"
	else
		fail "${label} -- 未找到: ${needle}"
	fi
}

# 断言输出不包含指定子串
expect_not_contains() {
	local output="$1"
	local needle="$2"
	local label="$3"

	if printf '%s' "${output}" | grep -qF -- "${needle}"; then
		fail "${label} -- 不应出现: ${needle}"
	else
		pass "${label}"
	fi
}

# 搭建一个满足"必需文件/目录"检查的最小项目骨架
make_skeleton() {
	local dir="$1"

	mkdir -p "${dir}/docs/modules/backend" "${dir}/test_cases/backend/unit" "${dir}/test_cases/stress"
	echo "# AGENTS" > "${dir}/AGENTS.md"
	echo "# README" > "${dir}/README.md"
	echo ".DS_Store" > "${dir}/.gitignore"
	echo "root = true" > "${dir}/.editorconfig"
	echo "* text eol=lf" > "${dir}/.gitattributes"
	echo "# demo 模块" > "${dir}/docs/modules/backend/demo.md"
	echo "# demo 用例" > "${dir}/test_cases/backend/unit/demo.md"
	printf '/**\n * 接口压力测试脚本\n * 创建日期：2026-09-21\n * 修改日期：2026-09-21\n */\nexport default function () {}\n' > "${dir}/test_cases/stress/load-test.js"
}

# 在指定目录里跑 check.sh，输出与退出码分别存入全局变量
run_check() {
	local dir="$1"

	CHECK_OUTPUT="$(cd "${dir}" && bash "${CHECK_SH}" 2>&1)"
	CHECK_EXIT=$?
}

# ============================================================
# 场景一：全部合规文件，七项检查应零违规、退出码 0
# ============================================================
echo "=== 场景一：合规项目应全绿 ==="
GOOD_DIR="$(mktemp -d)"
make_skeleton "${GOOD_DIR}"

cat > "${GOOD_DIR}/GoodService.java" <<'EOF'
/**
 * 订单服务
 * 创建日期：2026-08-31
 * 修改日期：2026-08-31
 */
public class GoodService {

	/**
	 * 按 ID 查询订单，未命中抛 OrderNotFoundException
	 *
	 * @param orderId 订单 ID
	 * @return 订单实体
	 */
	public Order getOrder(long orderId) {
		return null;
	}
}
EOF

cat > "${GOOD_DIR}/good-style.css" <<'EOF'
:root {
	--bg-primary: #ffffff;
	--text-main: #1f2a44;
}

.order-list,
.order-detail {
	background: var(--bg-primary);
}
EOF

cat > "${GOOD_DIR}/PageUserVO.java" <<'EOF'
/**
 * 用户分页查询的框架基类
 * 创建日期：2026-09-21
 * 修改日期：2026-09-21
 */
public class PageUserVO {

	/**
	 * 按条件分页查询用户
	 *
	 * @param pageNo 页码
	 * @param pageSize 每页条数
	 * @param keyword 关键字
	 * @return 用户分页结果
	 */
	public Object queryUsers(int pageNo, int pageSize, String keyword) {
		return null;
	}
}
EOF

cat > "${GOOD_DIR}/countdown.ts" <<'EOF'
/**
 * 倒计时递减与业务术语用词的放行样例
 * 创建日期：2026-09-21
 * 修改日期：2026-09-21
 */
export const tickDown = (start: number): number => {
	let remaining = start;
	remaining--;
	return remaining;
};

// 按运单号汇总包裹重量
export const sumParcelWeight = (weights: number[]): number => {
	let total = 0;

	for (const weight of weights) {
		total += weight;
	}

	return total;
};

// 这里保留隐喻说法作为反例演示 -- 搬运 check-ignore
export const legacyNote = 1;
EOF

cat > "${GOOD_DIR}/good-import.ts" <<'EOF'
/**
 * 装配仪表盘展示数据
 * 创建日期：2026-09-21
 * 修改日期：2026-09-21
 */
import { getDashboard } from "@/api/dashboard";

import type { EChartsOption } from "echarts";

export const chartOption: EChartsOption = {};
EOF

cat > "${GOOD_DIR}/deploy.yml" <<'EOF'
# 定义生产环境的容器编排与端口映射
# 创建日期：2026-09-21
# 修改日期：2026-09-21
version: "3"
EOF

cat > "${GOOD_DIR}/Makefile" <<'EOF'
# 提供构建与测试的统一入口
# 创建日期：2026-09-21
# 修改日期：2026-09-21

all:
	@echo ok
EOF

cat > "${GOOD_DIR}/GoodReqVO.ts" <<'EOF'
/**
 * 订单请求出入参类型定义
 * 创建日期：2026-08-31
 * 修改日期：2026-08-31
 */
export interface OrderSaveReqVO {
	orderId: number;
}

export interface OrderRespVO {
	orderId: number;
}

export const barChartHeight = 10;
export const orderList: OrderRespVO[] = [];
export const response1 = "ok";

// 图片地址表 -- URL 里的双斜杠不得被当成注释,行尾逗号也不算句子折断
export const orderImages = {
	hero: "https://example.com/hero.png",
	detail: "https://example.com/detail.png",
};
EOF

cat > "${GOOD_DIR}/good_service.py" <<'EOF'
# -*- coding: utf-8 -*-
"""
订单服务
创建日期：2026-08-31
修改日期：2026-08-31
"""

# 单次批量处理的最大订单数
MAX_BATCH_SIZE = 100


def get_order(order_id: int) -> None:
    """
    按 ID 查询订单，未命中返回 None
    """
    return None
EOF

cat > "${GOOD_DIR}/good_service.go" <<'EOF'
/*
 * 订单服务
 * 创建日期：2026-08-31
 * 修改日期：2026-08-31
 */
package service

// GetOrder 按 ID 查询订单，未命中返回 ErrOrderNotFound。
// 调用方需自行处理 ctx 取消。
// 本函数不做重试。
func GetOrder(id int64) error {
	return nil
}
EOF

cat > "${GOOD_DIR}/GoodPage.vue" <<'EOF'
<!--
	订单列表页
	创建日期：2026-08-31
	修改日期：2026-08-31
-->
<template>
	<div>orders</div>
</template>
EOF

cat > "${GOOD_DIR}/good_migrate.sql" <<'EOF'
-- 将已完成订单迁移至归档表
-- 创建日期：2026-08-31
-- 修改日期：2026-08-31
SELECT 1;
EOF

cat > "${GOOD_DIR}/good_tool.sh" <<'EOF'
#!/usr/bin/env bash
# 本地开发辅助脚本
# 创建日期：2026-08-31
# 修改日期：2026-08-31
echo "ok"
EOF

cat > "${GOOD_DIR}/good_style.css" <<'EOF'
:root {
	--order-bg: #ffffff;
	--order-line: #d2d2d7;
}

.order-list {
	color: red;
}
EOF

cat > "${GOOD_DIR}/UnknownCreateDate.java" <<'EOF'
/**
 * 无法从历史确认创建日期的兼容示例
 * 创建日期：
 * 修改日期：2026-09-14
 */
public class UnknownCreateDate {
}
EOF

# 头部合规,正文第 100 行附近含"创建日期: "半角冒号的 UI 字符串 -- 内容检查限定前 80 行后不应误报
{
	printf '/**\n * 报表导出服务\n * 创建日期：2026-08-31\n * 修改日期：2026-08-31\n */\npublic class GoodReport {\n'
	awk 'BEGIN { for (i = 1; i <= 94; i++) { printf "\tprivate int field%d = %d;\n", i, i } }'
	printf '\tprivate String buildLabel(String date) {\n\t\treturn "创建日期: " + date;\n\t}\n}\n'
} > "${GOOD_DIR}/GoodReport.java"

run_check "${GOOD_DIR}"

expect_not_contains "${CHECK_OUTPUT}" "[FAIL]" "合规项目无任何 FAIL(含正文半角冒号 UI 字符串不误报)"

if [ "${CHECK_EXIT}" -eq 0 ]; then
	pass "合规项目退出码为 0"
else
	fail "合规项目退出码应为 0，实际 ${CHECK_EXIT}"
	printf '%s\n' "${CHECK_OUTPUT}" | grep 'FAIL' | sed 's/^/         /'
fi

rm -rf "${GOOD_DIR}"

# ============================================================
# 场景二：违规文件逐项命中，退出码非 0
# ============================================================
echo "=== 场景二：违规项目逐项命中 ==="
BAD_DIR="$(mktemp -d)"
make_skeleton "${BAD_DIR}"

# 禁用字符三类：弯引号 / em dash / Emoji(用字节转义生成，仓库自身不含被禁字符)
printf 'quote \xe2\x80\x98x\xe2\x80\x99\n' > "${BAD_DIR}/bad_quote.txt"
printf 'dash \xe2\x80\x94 here\n' > "${BAD_DIR}/bad_dash.txt"
printf 'emoji \xf0\x9f\x98\x80 here\n' > "${BAD_DIR}/bad_emoji.txt"

cat > "${BAD_DIR}/HalfColon.java" <<'EOF'
/**
 * 日期冒号写成半角的文件
 * 创建日期: 2026-08-31
 * 修改日期: 2026-08-31
 */
public class HalfColon {
}
EOF

cat > "${BAD_DIR}/Legacy.java" <<'EOF'
/**
 * 文件作用：带前缀标签的老写法
 * 创建日期：2026-08-31
 * 修改日期：2026-08-31
 */
public class Legacy {
}
EOF

cat > "${BAD_DIR}/Period.java" <<'EOF'
/**
 * 描述结尾带了句号。
 * 创建日期：2026-08-31
 * 修改日期：2026-08-31
 */
public class Period {
}
EOF

cat > "${BAD_DIR}/NoDesc.java" <<'EOF'
/**
 * @author Charles_XDXD
 * 创建日期：2026-08-31
 * 修改日期：2026-08-31
 */
public class NoDesc {
}
EOF

cat > "${BAD_DIR}/NoModified.java" <<'EOF'
/**
 * 缺修改日期的文件
 * 创建日期：2026-08-31
 */
public class NoModified {
}
EOF

cat > "${BAD_DIR}/BadDate.java" <<'EOF'
/**
 * 日期格式错误的文件
 * 创建日期：2026/08/31
 * 修改日期：2026-13-40
 */
public class BadDate {
}
EOF

cat > "${BAD_DIR}/SlashHeader.ts" <<'EOF'
// 用单行注释写文件头
// 创建日期：2026-08-31
// 修改日期：2026-08-31
export const x = 1;
EOF

cat > "${BAD_DIR}/InlineBlock.java" <<'EOF'
/**
 * 块注释挤行示例
 * 创建日期：2026-08-31
 * 修改日期：2026-08-31
 */
public class InlineBlock {
	/** 挤在一行的注释 */
	private int x;
}
EOF

cat > "${BAD_DIR}/hash_header.py" <<'EOF'
# -*- coding: utf-8 -*-
# 用井号注释写文件头
# 创建日期：2026-08-31
# 修改日期：2026-08-31
X = 1
EOF

cat > "${BAD_DIR}/inline_doc.py" <<'EOF'
# -*- coding: utf-8 -*-
"""
docstring 正文与引号挤同一行的示例
创建日期：2026-08-31
修改日期：2026-08-31
"""


def get_order(order_id: int) -> None:
    """按 ID 查询订单"""
    return None
EOF

cat > "${BAD_DIR}/single_quote.py" <<'EOF'
# -*- coding: utf-8 -*-
"""
单引号三引号 docstring 的示例
创建日期：2026-08-31
修改日期：2026-08-31
"""


def get_order(order_id: int) -> None:
    '''
    按 ID 查询订单
    '''
    return None
EOF

cat > "${BAD_DIR}/LongDoc.java" <<'EOF'
/**
 * 注释超长的文件
 * 创建日期：2026-08-31
 * 修改日期：2026-08-31
 */
public class LongDoc {

	/**
	 * 把滞留任务标记失败
	 * 进程模型是任务活在进程里
	 * 一停就没了状态还留在处理中
	 * 所以这里要给出明确原因
	 */
	private void recover() {
	}
}
EOF

cat > "${BAD_DIR}/longrun.go" <<'EOF'
/*
 * 连续单行注释超长的文件
 * 创建日期：2026-08-31
 * 修改日期：2026-08-31
 */
package service

// Recover 把滞留任务标记失败。
// 进程模型是任务活在进程里。
// 一停就没了状态还留在处理中。
// 所以这里要给出明确原因。
func Recover() {
}
EOF

cat > "${BAD_DIR}/longdoc.py" <<'EOF'
# -*- coding: utf-8 -*-
"""
docstring 超长的文件
创建日期：2026-08-31
修改日期：2026-08-31
"""


def recover() -> None:
    """
    把滞留任务标记失败
    进程模型是任务活在进程里
    一停就没了状态还留在处理中
    所以这里要给出明确原因
    """
    return None
EOF

cat > "${BAD_DIR}/BrokenLine.java" <<'EOF'
/**
 * 追问上下文校验
 * 创建日期：2026-09-07
 * 修改日期：2026-09-07
 */
public class BrokenLine {

	/**
	 * 校验追问请求的阶段号与会话状态，
	 * 不合法时抛 IllegalStateException
	 */
	private void verify() {
	}
}
EOF

cat > "${BAD_DIR}/broken_line.py" <<'EOF'
# -*- coding: utf-8 -*-
"""
追问上下文定义
创建日期：2026-09-07
修改日期：2026-09-07
"""


class FollowUpContext:
    """
    三个意图 Handler 共用的只读上下文: 本次追问请求、目标阶段 workspace、
    会话句柄, 以及该阶段已确认 artifact 的 id
    """
EOF

cat > "${BAD_DIR}/BadName.ts" <<'EOF'
/**
 * 命名反例 -- 占位名与口语函数名
 * 创建日期：2026-09-03
 * 修改日期：2026-09-03
 */
const tmp = 1;
let item1 = 2;

export function doIt(): number {
	return tmp + item1;
}
EOF

cat > "${BAD_DIR}/bad_name.py" <<'EOF'
# -*- coding: utf-8 -*-
"""
命名反例 -- 占位变量与口语函数名
创建日期：2026-09-03
修改日期：2026-09-03
"""

obj = {}


def do_something() -> None:
    return None
EOF

cat > "${BAD_DIR}/Jargon.java" <<'EOF'
/**
 * 订单服务 -- 承载下单逻辑
 * 创建日期：2026-09-03
 * 修改日期：2026-09-03
 */
public class Jargon {

	private int count = 1; // 把核验结果压成下游要的一行

	/**
	 * 从 MCP 信封里拆出商品数据
	 */
	private void run() {
	}
}
EOF

cat > "${BAD_DIR}/jargon.py" <<'EOF'
# -*- coding: utf-8 -*-
"""
订单服务 -- 承载下单逻辑
创建日期：2026-09-03
修改日期：2026-09-03
"""


def run() -> None:
    """
    把上游数据灌进去，形状不符时丢弃
    """
    return None
EOF

cat > "${BAD_DIR}/BadVO.ts" <<'EOF'
/**
 * 裸 VO 命名的类型定义
 * 创建日期：2026-08-31
 * 修改日期：2026-08-31
 */
export interface OrderVO {
	orderId: number;
}
EOF

run_check "${BAD_DIR}"

expect_contains "${CHECK_OUTPUT}" "bad_quote.txt 含非法引号" "检查一:弯引号"
expect_contains "${CHECK_OUTPUT}" "bad_dash.txt 含 Unicode 破折号" "检查一:em dash"
expect_contains "${CHECK_OUTPUT}" "bad_emoji.txt 含 Emoji" "检查一:Emoji"
expect_contains "${CHECK_OUTPUT}" "HalfColon.java 日期行用了半角冒号" "检查二:半角冒号"
expect_contains "${CHECK_OUTPUT}" "Legacy.java 文件头带了前缀标签" "检查二:前缀标签"
expect_contains "${CHECK_OUTPUT}" "Period.java 文件头作用描述行结尾带了句号" "检查二:描述句号"
expect_contains "${CHECK_OUTPUT}" "NoDesc.java 缺少文件头作用描述行" "检查二:缺描述行"
expect_contains "${CHECK_OUTPUT}" 'NoModified.java 缺少"修改日期："' "检查二:缺修改日期"
expect_contains "${CHECK_OUTPUT}" "BadDate.java 创建日期格式错误" "检查二:创建日期格式"
expect_contains "${CHECK_OUTPUT}" "BadDate.java 修改日期格式错误" "检查二:修改日期格式"
expect_contains "${CHECK_OUTPUT}" "SlashHeader.ts 文件头用了 // 单行注释" "检查五:C系文件头用单行注释"
expect_contains "${CHECK_OUTPUT}" "InlineBlock.java 块注释挤在一行" "检查五:块注释挤行"
expect_contains "${CHECK_OUTPUT}" "hash_header.py 文件头用了 # 单行注释" "检查五:Python文件头用井号"
expect_contains "${CHECK_OUTPUT}" "inline_doc.py docstring 未三段式" "检查五:docstring挤行"
expect_contains "${CHECK_OUTPUT}" "single_quote.py 用了单引号三引号" "检查五:单引号三引号"
expect_contains "${CHECK_OUTPUT}" "LongDoc.java 注释块正文超过" "检查六:Javadoc超长"
expect_contains "${CHECK_OUTPUT}" "longrun.go 注释块正文超过" "检查六:连续单行注释超长"
expect_contains "${CHECK_OUTPUT}" "longdoc.py docstring 正文超过" "检查六:docstring超长"
expect_contains "${CHECK_OUTPUT}" "BrokenLine.java 注释正文句子被折断" "检查六:Javadoc 句子折断"
expect_contains "${CHECK_OUTPUT}" "broken_line.py 注释正文句子被折断" "检查六:docstring 句子折断"
expect_contains "${CHECK_OUTPUT}" "BadVO.ts 存在裸 VO 命名" "检查四:裸VO"
expect_contains "${CHECK_OUTPUT}" "BadName.ts 存在无意义/口语命名" "检查四:TS 占位名与口语函数名"
expect_contains "${CHECK_OUTPUT}" "bad_name.py 存在无意义/口语命名" "检查四:Python 占位名与口语函数名"
expect_contains "${CHECK_OUTPUT}" "Jargon.java 注释含隐喻/口语表达" "检查七:Java 注释黑话(块注释 + 行尾注释)"
expect_contains "${CHECK_OUTPUT}" "jargon.py 注释含隐喻/口语表达" "检查七:Python docstring 黑话"

if [ "${CHECK_EXIT}" -ne 0 ]; then
	pass "违规项目退出码非 0"
else
	fail "违规项目退出码应非 0，实际 0"
fi

rm -rf "${BAD_DIR}"

# ============================================================
# 场景三：项目级必需文件/目录缺失
# ============================================================
echo "=== 场景三：必需文件与目录结构 ==="
MISS_DIR="$(mktemp -d)"
make_skeleton "${MISS_DIR}"
rm "${MISS_DIR}/AGENTS.md"
echo "# 一级模块文档" > "${MISS_DIR}/docs/modules/flat.md"

run_check "${MISS_DIR}"

expect_contains "${CHECK_OUTPUT}" "缺少必需文件：AGENTS.md" "检查三:缺 AGENTS.md"
expect_contains "${CHECK_OUTPUT}" "docs/modules/ 下有一级模块文档" "检查三:模块文档层级"

if [ "${CHECK_EXIT}" -ne 0 ]; then
	pass "缺失场景退出码非 0"
else
	fail "缺失场景退出码应非 0，实际 0"
fi

rm -rf "${MISS_DIR}"


# ============================================================
# 场景四：此前漏检的四类违规必须被拦住
# ============================================================
echo "=== 场景四：扩展扫描范围与文件头回溯 ==="
GAP_DIR="$(mktemp -d)"
make_skeleton "${GAP_DIR}"

# 带 package 的 Java 缺描述行：回溯不得把 package/import 当成描述行
cat > "${GAP_DIR}/NoDesc.java" <<'EOF'
package com.demo;

import java.util.List;

/**
 * 创建日期：2026-01-01
 * 修改日期：2026-01-02
 */
public class NoDesc {
}
EOF

# 单独的"作用："前缀标签
cat > "${GAP_DIR}/prefix.sh" <<'EOF'
# 作用：构建并校验项目交付产物
# 创建日期：2026-01-01
# 修改日期：2026-01-02

echo hi
EOF

# YAML：既缺文件头也含黑话
cat > "${GAP_DIR}/deploy.yml" <<'EOF'
# 把配置塞进容器，喂给下游服务
version: "3"
EOF

# Makefile：日期行用半角冒号
cat > "${GAP_DIR}/Makefile" <<'EOF'
# 提供构建与测试的统一入口
# 创建日期: 2026-07-29
# 修改日期：2026-07-29

all:
	@echo hi
EOF

run_check "${GAP_DIR}"
expect_contains "${CHECK_OUTPUT}" "NoDesc.java 缺少文件头作用描述行" "检查二:带 package 仍能判缺描述行"
expect_contains "${CHECK_OUTPUT}" "prefix.sh 文件头带了前缀标签" "检查二:单独的作用前缀标签"
expect_contains "${CHECK_OUTPUT}" "deploy.yml 缺少" "检查二:YAML 纳入文件头校验"
expect_contains "${CHECK_OUTPUT}" "deploy.yml 注释含隐喻" "检查七:YAML 注释纳入黑话校验"
expect_contains "${CHECK_OUTPUT}" "Makefile 日期行用了半角冒号" "检查二:Makefile 纳入校验"

rm -rf "${GAP_DIR}"

# ============================================================
# 场景五：豁免机制(文件级 .checkignore 与行级 check-ignore)
# ============================================================
echo "=== 场景五：豁免机制 ==="
IGNORE_DIR="$(mktemp -d)"
make_skeleton "${IGNORE_DIR}"

cat > "${IGNORE_DIR}/bad-example.yml" <<'EOF'
# 把配置塞进容器，喂给下游服务
version: "3"
EOF

cat > "${IGNORE_DIR}/inline.sh" <<'EOF'
# 构建并校验项目交付产物
# 创建日期：2026-01-01
# 修改日期：2026-01-02

# 这一行故意保留隐喻作为文档反例 -- 搬运 check-ignore
echo hi
EOF

run_check "${IGNORE_DIR}"
expect_contains "${CHECK_OUTPUT}" "bad-example.yml" "豁免前:反例文件确实会被报出来"

printf 'bad-example.yml\n' > "${IGNORE_DIR}/.checkignore"
run_check "${IGNORE_DIR}"
expect_not_contains "${CHECK_OUTPUT}" "bad-example.yml" "豁免后:.checkignore 命中的文件被跳过"
expect_not_contains "${CHECK_OUTPUT}" "inline.sh 注释含隐喻" "行级 check-ignore 跳过该行"

rm -rf "${IGNORE_DIR}"

# ============================================================
# 场景六：增量模式只检查本次改动
# ============================================================
echo "=== 场景六：增量检查 ==="
INC_DIR="$(mktemp -d)"
make_skeleton "${INC_DIR}"
(
	cd "${INC_DIR}" || exit 1
	git init -q .
	git config user.email test@example.com
	git config user.name test
	printf 'const tmp = 1;\nexport function doIt() { return tmp; }\n' > legacy.ts
	git add -A
	git commit -qm "存量代码"
	git branch -M main
	git checkout -qb agents/feature/incremental
	cat > clean.ts <<'INNER'
/**
 * 计算订单总价
 * 创建日期：2026-09-21
 * 修改日期：2026-09-21
 */
export const calculateTotal = (prices: number[]): number => {
	let total = 0;

	for (const price of prices) {
		total += price;
	}

	return total;
};
INNER
	git add -A
	git commit -qm "新增合规文件"
) >/dev/null 2>&1

run_check "${INC_DIR}"
expect_contains "${CHECK_OUTPUT}" "legacy.ts" "全量模式:存量违规被报出"

CHECK_OUTPUT="$(cd "${INC_DIR}" && bash "${CHECK_SH}" --changed 2>&1)"
CHECK_EXIT=$?
expect_not_contains "${CHECK_OUTPUT}" "legacy.ts" "增量模式:未改动的存量文件被跳过"

if [ "${CHECK_EXIT}" -eq 0 ]; then
	pass "增量模式:本次改动合规则退出码 0"
else
	fail "增量模式:本次改动合规但退出码为 ${CHECK_EXIT}"
fi

rm -rf "${INC_DIR}"

# ============================================================
# 场景七：模块访问边界(单一入口)
# ============================================================
echo "=== 场景七：模块访问边界 ==="
BOUNDARY_DIR="$(mktemp -d)"
make_skeleton "${BOUNDARY_DIR}"
mkdir -p "${BOUNDARY_DIR}/src/utils" "${BOUNDARY_DIR}/src/composables" "${BOUNDARY_DIR}/src/store"

cat > "${BOUNDARY_DIR}/src/utils/auth.ts" <<'EOF'
/**
 * 读取与刷新本地认证令牌
 * 创建日期：2026-09-21
 * 修改日期：2026-09-21
 */
export const readToken = (): string | null => localStorage.getItem('token');
EOF

cat > "${BOUNDARY_DIR}/src/composables/useAuth.ts" <<'EOF'
/**
 * 对外提供认证状态与登录登出操作
 * 创建日期：2026-09-21
 * 修改日期：2026-09-21
 */
import { readToken } from '../utils/auth';

export const useAuth = () => ({ token: readToken() });
EOF

cat > "${BOUNDARY_DIR}/src/store/authStore.ts" <<'EOF'
/**
 * 保存全局认证状态
 * 创建日期：2026-09-21
 * 修改日期：2026-09-21
 */
import { readToken } from '../utils/auth';

export const authState = { token: readToken() };
EOF

run_check "${BOUNDARY_DIR}"
expect_not_contains "${CHECK_OUTPUT}" "绕过入口" "未配置边界时不做检查"

printf 'utils/auth | composables/useAuth\n' > "${BOUNDARY_DIR}/.import-boundaries"
run_check "${BOUNDARY_DIR}"
expect_contains "${CHECK_OUTPUT}" "authStore.ts 绕过入口直接引用受保护模块" "检查八:拦截绕过入口的引用"
expect_not_contains "${CHECK_OUTPUT}" "useAuth.ts 绕过入口" "检查八:白名单内的入口文件放行"
expect_not_contains "${CHECK_OUTPUT}" "auth.ts 绕过入口直接引用" "检查八:受保护模块自身放行"

rm -rf "${BOUNDARY_DIR}"


# ============================================================
# 场景八：样式注释与 import 排版
# ============================================================
echo "=== 场景八：样式注释与 import 排版 ==="
STYLE_DIR="$(mktemp -d)"
make_skeleton "${STYLE_DIR}"

# 违规：CSS 文件写了注释(含文件头)
cat > "${STYLE_DIR}/bad.css" <<'EOF'
/*
 * 定义页面布局
 * 创建日期：2026-01-01
 * 修改日期：2026-01-02
 */
.hero {
	color: red;
}
EOF

# 合规：CSS 无注释也无文件头
cat > "${STYLE_DIR}/good.css" <<'EOF'
:root {
	--bg-primary: #ffffff;
}

.order-list {
	background: var(--bg-primary);
}
EOF

# 违规：style 块内有注释；模板与脚本的注释必须放行
cat > "${STYLE_DIR}/Bad.vue" <<'EOF'
<!--
展示订单列表
创建日期：2026-01-01
修改日期：2026-01-02
-->
<template>
	<!-- 模板注释允许存在 -->
	<div
		class="order"
	>
	</div>
</template>

<script setup lang="ts">
// 脚本注释允许存在
const orderTotal = 1;
</script>

<style scoped>
/* 这条注释违规 */
.order {
	color: red;
}
</style>
EOF

# 违规：type import 排在值 import 之前
cat > "${STYLE_DIR}/bad-order.ts" <<'EOF'
/**
 * 装配仪表盘数据
 * 创建日期：2026-01-01
 * 修改日期：2026-01-02
 */
import type { EChartsOption } from "echarts";
import { getDashboard } from "@/api/dashboard";

export const chartOption: EChartsOption = {};
EOF

run_check "${STYLE_DIR}"
expect_contains "${CHECK_OUTPUT}" "bad.css 样式里写了注释" "检查九:CSS 文件头注释被拦"
expect_not_contains "${CHECK_OUTPUT}" "good.css" "检查九:无注释的 CSS 放行且不要求文件头"
expect_contains "${CHECK_OUTPUT}" "Bad.vue 样式里写了注释" "检查九:style 块注释被拦"
expect_contains "${CHECK_OUTPUT}" "bad-order.ts import 排版错误" "检查十:type import 排在值 import 之前被拦"

rm -rf "${STYLE_DIR}"


# ============================================================
# 场景九：文件头描述、测试位置与压测
# ============================================================
echo "=== 场景九：描述粒度、测试位置与压测 ==="
DELIVERY_DIR="$(mktemp -d)"
make_skeleton "${DELIVERY_DIR}"
mkdir -p "${DELIVERY_DIR}/src/utils" "${DELIVERY_DIR}/tests/utils"

# 违规：文件头描述用 -- 追加功能罗列
cat > "${DELIVERY_DIR}/LoginPage.vue" <<'EOF'
<!--
用户登录页 -- 用户名密码输入、前端校验与提交
创建日期：2026-01-01
修改日期：2026-01-02
-->
<template>
	<div
		class="login"
	>
	</div>
</template>
EOF

# 违规：测试代码散落在源码目录旁
cat > "${DELIVERY_DIR}/src/utils/format.test.ts" <<'EOF'
/**
 * 格式化工具测试
 * 创建日期：2026-01-01
 * 修改日期：2026-01-02
 */
export const noop = 1;
EOF

# 合规：测试集中放 tests/
cat > "${DELIVERY_DIR}/tests/utils/parse.test.ts" <<'EOF'
/**
 * 解析工具测试
 * 创建日期：2026-01-01
 * 修改日期：2026-01-02
 */
export const noop = 1;
EOF

run_check "${DELIVERY_DIR}"
expect_contains "${CHECK_OUTPUT}" "LoginPage.vue 文件头描述用 -- 追加了功能说明" "检查二:描述行 -- 追加说明被拦"
expect_contains "${CHECK_OUTPUT}" "format.test.ts 测试代码散落在源码目录" "检查十一:散落的测试文件被拦"
expect_not_contains "${CHECK_OUTPUT}" "parse.test.ts 测试代码散落" "检查十一:集中在 tests/ 的测试放行"

# 压测目录被清空后必须报缺失
rm -rf "${DELIVERY_DIR}/test_cases/stress"
run_check "${DELIVERY_DIR}"
expect_contains "${CHECK_OUTPUT}" "缺少压测目录" "检查十二:缺压测目录被拦"

rm -rf "${DELIVERY_DIR}"

# ============================================================
# 场景十：集合写法与 Python 类型注解
# ============================================================
echo "=== 场景十：集合写法与类型注解 ==="
LOOP_DIR="$(mktemp -d)"
make_skeleton "${LOOP_DIR}"
mkdir -p "${LOOP_DIR}/tests/e2e"

# 违规：Python 推导式、map() 调用、海象运算符与嵌套三元
cat > "${LOOP_DIR}/bad_comprehension.py" <<'EOF'
# -*- coding: utf-8 -*-
"""
竞品站点标注的清洗
创建日期：2026-09-24
修改日期：2026-09-24
"""


def competitor_sites_of(sites: dict[str, str]) -> dict[str, str]:
    """
    清洗竞品 ASIN 到站点代码的映射
    """
    return {
        asin.strip().upper(): site.strip().upper()
        for asin, site in sites.items()
        if asin.strip() and site.strip()
    }


def list_codes(sites: dict[str, str]) -> list[str]:
    """
    列出全部站点代码
    """
    return list(map(str.upper, sites.values()))


def pick_label(sites: dict[str, str]) -> str:
    """
    按站点数量返回档位标签
    """
    if (site_count := len(sites)) == 0:
        return "none"

    return "many" if site_count > MANY_SITES else "few" if site_count > 1 else "one"
EOF

# 违规：函数缺少参数注解与返回类型，__init__ 也要写 -> None
cat > "${LOOP_DIR}/bad_annotation.py" <<'EOF'
# -*- coding: utf-8 -*-
"""
订单文件读取
创建日期：2026-09-24
修改日期：2026-09-24
"""


def load_orders(path):
    """
    读取订单文件
    """
    return path


class OrderLoader:
    """
    订单文件读取器
    """

    def __init__(self, path: str):
        self.path = path
EOF

# 合规：显式循环、sorted 的 key lambda、ORM 的 filter 方法与行级豁免都要放行
cat > "${LOOP_DIR}/good_loop.py" <<'EOF'
# -*- coding: utf-8 -*-
"""
订单查询与排序
创建日期：2026-09-24
修改日期：2026-09-24
"""


class OrderRepository:
    """
    订单数据访问
    """

    def __init__(self, session: Session) -> None:
        self.session = session

    @classmethod
    def build(cls, session: Session) -> "OrderRepository":
        return cls(session)

    def list_paid(self, orders: list[Order]) -> list[Order]:
        """
        按下单时间排序已支付订单
        """
        paid: list[Order] = []

        for order in orders:
            if not order.paid:
                continue

            paid.append(order)

        return sorted(paid, key=lambda order: order.created_at)

    def query_by_id(self, order_id: int) -> Query:
        """
        按 ID 查询订单
        """
        legacy_ids = [order_id for _ in range(1)]  # check-ignore
        return self.session.query(Order).filter(Order.id.in_(legacy_ids))
EOF

# 违规：Stream 链与 Optional 链
cat > "${LOOP_DIR}/BadStream.java" <<'EOF'
/**
 * 用户名单汇总
 * 创建日期：2026-09-24
 * 修改日期：2026-09-24
 */
public class BadStream {

	public List<String> listNames(List<User> users) {
		return users.stream()
			.map(User::getName)
			.collect(Collectors.toList());
	}

	public String findCity(User user) {
		return Optional.ofNullable(user).map(User::getCity).orElse("");
	}
}
EOF

# 合规：显式循环，注释里提到 Stream 不算违规
cat > "${LOOP_DIR}/GoodLoop.java" <<'EOF'
/**
 * 用户名单汇总
 * 创建日期：2026-09-24
 * 修改日期：2026-09-24
 */
public class GoodLoop {

	public List<String> listNames(List<User> users) {
		List<String> names = new ArrayList<>();

		for (User user : users) {
			names.add(user.getName());
		}

		return names;
	}

	public String findCity(Optional<User> user) {
		// 不再写 list.stream() 链式调用
		return user.orElseThrow().getCity();
	}
}
EOF

# 违规：数组回调链
cat > "${LOOP_DIR}/bad-chain.ts" <<'EOF'
/**
 * 计算已支付订单总额
 * 创建日期：2026-09-24
 * 修改日期：2026-09-24
 */
export const paidAmount = (orders: Order[]): number => orders.filter((order) => order.paid).reduce((sum, order) => sum + order.amount, 0);
EOF

# 合规：JSX 渲染列表时单独一次 map、查找类单次调用
cat > "${LOOP_DIR}/GoodList.tsx" <<'EOF'
/**
 * 已支付订单列表
 * 创建日期：2026-09-24
 * 修改日期：2026-09-24
 */
export function OrderList({ orders }: OrderListProps) {
	const paidOrders: Order[] = [];

	for (const order of orders) {
		if (order.paid) {
			paidOrders.push(order);
		}
	}

	const firstPaid = orders.find((order) => order.paid);

	return (
		<ul>
			{paidOrders.map((order) => (
				<li
					key={order.id}
				>
					{order.name}
				</li>
			))}
		</ul>
	);
}
EOF

# 合规：Playwright 的 locator.filter 传对象，不是数组方法
cat > "${LOOP_DIR}/tests/e2e/orders.spec.ts" <<'EOF'
/**
 * 订单列表页端到端测试
 * 创建日期：2026-09-24
 * 修改日期：2026-09-24
 */
export const openPaidOrder = async (page: Page): Promise<void> => {
	await page.locator("li").filter({ hasText: "已支付" }).click();
};
EOF

# 违规：Kotlin 集合 forEach
cat > "${LOOP_DIR}/BadLoop.kt" <<'EOF'
/**
 * 订单打印
 * 创建日期：2026-09-24
 * 修改日期：2026-09-24
 */
class BadLoop {
    fun printOrders(orders: List<Order>) {
        orders.forEach { println(it) }
    }
}
EOF

# 合规：Flow 的 map 与集合 map 同名，属于手动约定，不得误拦
cat > "${LOOP_DIR}/OrderViewModel.kt" <<'EOF'
/**
 * 订单列表的界面状态
 * 创建日期：2026-09-24
 * 修改日期：2026-09-24
 */
class OrderViewModel(repository: OrderRepository) : ViewModel() {
    val orderCount = repository.orders.map { it.size }.stateIn(viewModelScope, SharingStarted.Lazily, 0)
}
EOF

# 违规：Go 引入函数式集合库，自写泛型集合辅助函数
printf 'module demo\n\nrequire github.com/samber/lo v1.39.0\n' > "${LOOP_DIR}/go.mod"

cat > "${LOOP_DIR}/helpers.go" <<'EOF'
/*
 * 集合辅助函数
 * 创建日期：2026-09-24
 * 修改日期：2026-09-24
 */
package helpers

func Map[T, U any](items []T, convert func(T) U) []U {
	return nil
}
EOF

run_check "${LOOP_DIR}"
expect_contains "${CHECK_OUTPUT}" "bad_comprehension.py 用了推导式或函数式简写" "检查十三:Python 推导式被拦"
expect_contains "${CHECK_OUTPUT}" "字典推导式" "检查十三:识别字典推导式"
expect_contains "${CHECK_OUTPUT}" "map() 调用" "检查十三:识别 map() 调用"
expect_contains "${CHECK_OUTPUT}" "海象运算符" "检查十三:识别海象运算符"
expect_contains "${CHECK_OUTPUT}" "嵌套三元表达式" "检查十三:识别嵌套三元"
expect_not_contains "${CHECK_OUTPUT}" "good_loop.py" "检查十三/十四:key lambda、ORM filter、行级豁免与 self/cls 放行"
expect_contains "${CHECK_OUTPUT}" "BadStream.java 用了流式或集合回调写法" "检查十三:Java Stream 与 Optional 链被拦"
expect_not_contains "${CHECK_OUTPUT}" "GoodLoop.java" "检查十三:Java 显式循环与注释放行"
expect_contains "${CHECK_OUTPUT}" "bad-chain.ts 用了流式或集合回调写法" "检查十三:TS 数组回调链被拦"
expect_not_contains "${CHECK_OUTPUT}" "GoodList.tsx" "检查十三:JSX 渲染列表的单次 map 与 find 放行"
expect_not_contains "${CHECK_OUTPUT}" "orders.spec.ts" "检查十三:Playwright 的 filter 传对象放行"
expect_contains "${CHECK_OUTPUT}" "BadLoop.kt 用了流式或集合回调写法" "检查十三:Kotlin forEach 被拦"
expect_not_contains "${CHECK_OUTPUT}" "OrderViewModel.kt" "检查十三:Kotlin Flow 的 map 放行"
expect_contains "${CHECK_OUTPUT}" "go.mod 用了流式或集合回调写法" "检查十三:Go 引入 samber/lo 被拦"
expect_contains "${CHECK_OUTPUT}" "helpers.go 用了流式或集合回调写法" "检查十三:Go 自写泛型 Map 被拦"
expect_contains "${CHECK_OUTPUT}" "bad_annotation.py 函数缺少类型注解" "检查十四:缺类型注解被拦"
expect_contains "${CHECK_OUTPUT}" "函数 load_orders 缺少返回类型" "检查十四:识别缺返回类型"
expect_contains "${CHECK_OUTPUT}" "函数 load_orders 的参数 path 缺少类型注解" "检查十四:识别缺参数注解"
expect_contains "${CHECK_OUTPUT}" "函数 __init__ 缺少返回类型" "检查十四:__init__ 也要写 -> None"

if [ "${CHECK_EXIT}" -ne 0 ]; then
	pass "集合写法场景退出码非 0"
else
	fail "集合写法场景退出码应非 0，实际 0"
fi

rm -rf "${LOOP_DIR}"

# ============================================================
# 汇总
# ============================================================
echo "==============================="
echo "通过 ${PASS_COUNT} 项，失败 ${FAIL_COUNT} 项"

if [ "${FAIL_COUNT}" -gt 0 ]; then
	exit 1
fi

exit 0
