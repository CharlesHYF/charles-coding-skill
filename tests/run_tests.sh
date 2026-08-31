#!/usr/bin/env bash
# check.sh 回归测试 -- 用固定 fixture 断言六项检查该报的都报、不该报的不报，防止规则改动静默退化
# 创建日期：2026-08-31
# 修改日期：2026-08-31

set -uo pipefail

# 被测脚本：模板里的规范校验器
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECK_SH="${REPO_ROOT}/reference/project-template/scripts/check.sh"

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

	mkdir -p "${dir}/docs/modules/backend" "${dir}/test_cases/backend/unit"
	echo "# AGENTS" > "${dir}/AGENTS.md"
	echo "# README" > "${dir}/README.md"
	echo ".DS_Store" > "${dir}/.gitignore"
	echo "root = true" > "${dir}/.editorconfig"
	echo "* text eol=lf" > "${dir}/.gitattributes"
	echo "# demo 模块" > "${dir}/docs/modules/backend/demo.md"
	echo "# demo 用例" > "${dir}/test_cases/backend/unit/demo.md"
}

# 在指定目录里跑 check.sh，输出与退出码分别存入全局变量
run_check() {
	local dir="$1"

	CHECK_OUTPUT="$(cd "${dir}" && bash "${CHECK_SH}" 2>&1)"
	CHECK_EXIT=$?
}

# ============================================================
# 场景一：全部合规文件，六项检查应零违规、退出码 0
# ============================================================
echo "=== 场景一：合规项目应全绿 ==="
GOOD_DIR="$(mktemp -d)"
make_skeleton "${GOOD_DIR}"

cat > "${GOOD_DIR}/GoodService.java" <<'EOF'
/**
 * 订单服务 -- 承载下单与退款的业务逻辑
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
EOF

cat > "${GOOD_DIR}/good_service.py" <<'EOF'
# -*- coding: utf-8 -*-
"""
订单服务 -- 承载下单与退款的业务逻辑
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
 * 订单服务 -- 承载下单与退款的业务逻辑
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
	订单列表页 -- 分页展示与筛选
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
# 本地开发辅助脚本 -- 打印环境信息
# 创建日期：2026-08-31
# 修改日期：2026-08-31
echo "ok"
EOF

cat > "${GOOD_DIR}/good_style.css" <<'EOF'
/*
 * 订单列表页样式
 * 创建日期：2026-08-31
 * 修改日期：2026-08-31
 */
.order-list {
	color: red;
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
expect_contains "${CHECK_OUTPUT}" "SlashHeader.ts 文件头用了 // 单行注释" "检查五:C系文件头用单行注释"
expect_contains "${CHECK_OUTPUT}" "InlineBlock.java 块注释挤在一行" "检查五:块注释挤行"
expect_contains "${CHECK_OUTPUT}" "hash_header.py 文件头用了 # 单行注释" "检查五:Python文件头用井号"
expect_contains "${CHECK_OUTPUT}" "inline_doc.py docstring 未三段式" "检查五:docstring挤行"
expect_contains "${CHECK_OUTPUT}" "single_quote.py 用了单引号三引号" "检查五:单引号三引号"
expect_contains "${CHECK_OUTPUT}" "LongDoc.java 注释块正文超过" "检查六:Javadoc超长"
expect_contains "${CHECK_OUTPUT}" "longrun.go 注释块正文超过" "检查六:连续单行注释超长"
expect_contains "${CHECK_OUTPUT}" "longdoc.py docstring 正文超过" "检查六:docstring超长"
expect_contains "${CHECK_OUTPUT}" "BadVO.ts 存在裸 VO 命名" "检查四:裸VO"

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
# 汇总
# ============================================================
echo "==============================="
echo "通过 ${PASS_COUNT} 项，失败 ${FAIL_COUNT} 项"

if [ "${FAIL_COUNT}" -gt 0 ]; then
	exit 1
fi

exit 0
