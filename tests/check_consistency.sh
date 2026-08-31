#!/usr/bin/env bash
# 多处同源规则一致性自检 -- 同一条规则活在 SKILL.md / README / AGENTS.md / check.sh 四处，本脚本断言关键取值互相咬合，防止改一处漏三处
# 创建日期：2026-08-31
# 修改日期：2026-08-31

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "${REPO_ROOT}"

SKILL="SKILL.md"
README="README.md"
AGENTS="reference/project-template/AGENTS.md"
MAKEFILE="reference/project-template/Makefile"
CHECK_SH="reference/project-template/scripts/check.sh"

PASS_COUNT=0
FAIL_COUNT=0

pass() {
	echo "  [PASS] $1"
	PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
	echo "  [FAIL] $1"
	FAIL_COUNT=$((FAIL_COUNT + 1))
}

# 断言文件包含指定子串
expect_in_file() {
	local file="$1"
	local needle="$2"
	local label="$3"

	if grep -qF -- "${needle}" "${file}"; then
		pass "${label}"
	else
		fail "${label} -- ${file} 中未找到: ${needle}"
	fi
}

echo "=== 一致性自检 ==="

# 一、版本号：SKILL.md frontmatter 与 README badge 必须一致
SKILL_VERSION=$(grep -m1 '^version:' "${SKILL}" | awk '{print $2}')
README_VERSION=$(grep -oE 'version-[0-9.]+-blue' "${README}" | head -1 | sed 's/version-//;s/-blue//')

if [ -n "${SKILL_VERSION}" ] && [ "${SKILL_VERSION}" = "${README_VERSION}" ]; then
	pass "版本号一致: ${SKILL_VERSION}"
else
	fail "版本号漂移: SKILL.md=${SKILL_VERSION} README badge=${README_VERSION}"
fi

# 二、注释篇幅上限：以 check.sh 的常量为准，文档三处必须引用同一数值
MAX_LINES=$(grep -m1 'MAX_COMMENT_BODY_LINES=' "${CHECK_SH}" | cut -d= -f2)

if [ -z "${MAX_LINES}" ]; then
	fail "check.sh 中未找到 MAX_COMMENT_BODY_LINES"
else
	expect_in_file "${SKILL}" "不得超过 ${MAX_LINES} 行" "篇幅上限 ${MAX_LINES} 行已写入 SKILL.md"
	expect_in_file "${AGENTS}" "硬上限 ${MAX_LINES} 行" "篇幅上限 ${MAX_LINES} 行已写入 AGENTS.md"
	expect_in_file "${README}" "硬上限 ${MAX_LINES} 行" "篇幅上限 ${MAX_LINES} 行已写入 README.md"
fi

# 三、lint 范围描述串：四处必须逐字一致
LINT_SCOPE="禁用字符/文件头/注释语法/注释篇幅/必需文件/命名"

expect_in_file "${CHECK_SH}" "${LINT_SCOPE}" "lint 范围串在 check.sh"
expect_in_file "${AGENTS}" "${LINT_SCOPE}" "lint 范围串在 AGENTS.md"
expect_in_file "${MAKEFILE}" "${LINT_SCOPE}" "lint 范围串在 Makefile"
expect_in_file "${README}" "${LINT_SCOPE}" "lint 范围串在 README.md"

# 四、检查项编号：check.sh 里 [k/N] 的 N 必须统一，且 k 覆盖 1..N 不重不漏
LABEL_TOTALS=$(grep -oE '\[[0-9]+/[0-9]+\]' "${CHECK_SH}" | cut -d/ -f2 | tr -d ']' | sort -u)
LABEL_TOTAL_COUNT=$(echo "${LABEL_TOTALS}" | wc -l | tr -d ' ')

if [ "${LABEL_TOTAL_COUNT}" -ne 1 ]; then
	fail "check.sh 检查编号分母不统一: $(echo "${LABEL_TOTALS}" | tr '\n' ' ')"
else
	EXPECTED_SEQ=$(seq 1 "${LABEL_TOTALS}")
	ACTUAL_SEQ=$(grep -oE '\[[0-9]+/[0-9]+\]' "${CHECK_SH}" | cut -d/ -f1 | tr -d '[' | sort -n -u)

	if [ "${EXPECTED_SEQ}" = "${ACTUAL_SEQ}" ]; then
		pass "检查编号连续覆盖 1..${LABEL_TOTALS}"
	else
		fail "检查编号不连续: 期望 1..${LABEL_TOTALS}，实际 $(echo "${ACTUAL_SEQ}" | tr '\n' ' ')"
	fi
fi

# 五、文件头模板：SKILL.md / AGENTS.md 与各语言分册都必须含全角冒号的日期模板
HEADER_FILES=(
	"${SKILL}"
	"${AGENTS}"
	"reference/java.md"
	"reference/go.md"
	"reference/python.md"
	"reference/ai-ml.md"
	"reference/kotlin-android.md"
	"reference/react.md"
	"reference/vue.md"
	"reference/sql.md"
)

for header_file in "${HEADER_FILES[@]}"; do
	expect_in_file "${header_file}" "创建日期：" "文件头模板(全角冒号)在 ${header_file}"
done

# 六、仓库自身不得含被禁字符(与 check.sh 检查一同源的三条 perl 规则)
FORBIDDEN_HITS=$(git ls-files | grep -vE '\.(png|jpe?g|gif|webp|ico|svg|pdf|zip|gz|tar|jar|woff2?|ttf|eot|lock)$' | while IFS= read -r tracked_file; do
	perl -CSD -ne 'print "'"${tracked_file}"' L$.: $_" if /[\x{2018}\x{2019}\x{201c}\x{201d}\x{300c}-\x{300f}\x{ff02}\x{ff07}\x{2010}-\x{2015}\x{2212}\x{2e3a}\x{2e3b}\x{ff0d}\x{1F300}-\x{1FAFF}\x{1F1E6}-\x{1F1FF}\x{FE0F}]/' "${tracked_file}" 2>/dev/null
done)

if [ -z "${FORBIDDEN_HITS}" ]; then
	pass "仓库自身无被禁字符"
else
	fail "仓库自身含被禁字符:"
	printf '%s\n' "${FORBIDDEN_HITS}" | head -10 | sed 's/^/         /'
fi

echo "==============================="
echo "通过 ${PASS_COUNT} 项，失败 ${FAIL_COUNT} 项"

if [ "${FAIL_COUNT}" -gt 0 ]; then
	exit 1
fi

exit 0
