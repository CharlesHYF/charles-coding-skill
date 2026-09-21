#!/usr/bin/env bash
# 多处同源规则一致性自检
# 创建日期：2026-08-31
# 修改日期：2026-09-21

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "${REPO_ROOT}" || exit 1

SKILL="skills/charles-coding-standards/SKILL.md"
README="README.md"
AGENTS="templates/project-template/AGENTS.md"
MAKEFILE="templates/project-template/Makefile"
CHECK_SH="tools/check.sh"
CHECK_SH_TEMPLATE="templates/project-template/scripts/check.sh"
ARCHITECTURE="skills/charles-coding-standards/rules/architecture.md"
COLLABORATION="skills/charles-coding-standards/rules/collaboration.md"
TEXT="skills/charles-coding-standards/rules/text.md"
PROCESS="skills/charles-coding-standards/rules/process.md"
VUE="skills/charles-coding-standards/stacks/vue.md"

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

# 一、版本号：SKILL.md metadata 与 README badge 必须一致
SKILL_VERSION=$(grep -m1 '^[[:space:]]*version:' "${SKILL}" | awk '{print $2}' | tr -d '"')
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
	expect_in_file "${TEXT}" "不得超过 ${MAX_LINES} 行" "篇幅上限 ${MAX_LINES} 行已写入 text.md"
	expect_in_file "${AGENTS}" "硬上限 ${MAX_LINES} 行" "篇幅上限 ${MAX_LINES} 行已写入 AGENTS.md"
	expect_in_file "${README}" "硬上限 ${MAX_LINES} 行" "篇幅上限 ${MAX_LINES} 行已写入 README.md"
fi

# 三、lint 范围描述串：四处必须逐字一致
LINT_SCOPE="禁用字符/文件头/注释语法/注释篇幅/注释黑话/必需文件/命名/模块边界/样式注释/import 排版/测试位置/压测"

expect_in_file "${CHECK_SH}" "${LINT_SCOPE}" "lint 范围串在 check.sh"
expect_in_file "${AGENTS}" "${LINT_SCOPE}" "lint 范围串在 AGENTS.md"
expect_in_file "${MAKEFILE}" "${LINT_SCOPE}" "lint 范围串在 Makefile"
expect_in_file "${README}" "${LINT_SCOPE}" "lint 范围串在 README.md"

# 四、规范模块必须可发现，项目模板必须内联关键边界
expect_in_file "${SKILL}" "rules/architecture.md" "架构与代码组织模块已接入 SKILL.md"
expect_in_file "${SKILL}" "rules/collaboration.md" "协作与交流模块已接入 SKILL.md"
expect_in_file "${SKILL}" "rules/process.md" "流程模块已接入 SKILL.md"
expect_in_file "${ARCHITECTURE}" "所有新写和修改的源码都必须遵守本规范" "代码编写与组织规范默认适用"
expect_in_file "${AGENTS}" "## 6. 代码编写与组织规范" "AGENTS.md 已内联代码编写与组织规则"
expect_in_file "${COLLABORATION}" "keep-coding-instructions: true" "Output Style 保留编码指令"
expect_in_file "${COLLABORATION}" "一等公民" "开发交流分册包含抽象表达改写"
expect_in_file "${VUE}" '### `<script setup>` 内部顺序' "Vue 分册包含脚本排列顺序"

# 四之二、变更类型闸门必须同时活在流程模块与项目模板里(子 agent 只认它直接读到的文件)
GATE_ROWS=("新模块 / 新功能" "需求变更" "Bug 修复" "重构" "依赖升级")

for gate_row in "${GATE_ROWS[@]}"; do
	expect_in_file "${PROCESS}" "${gate_row}" "闸门表含 ${gate_row} (process.md)"
	expect_in_file "${AGENTS}" "${gate_row}" "闸门表含 ${gate_row} (AGENTS.md)"
done

expect_in_file "${PROCESS}" "先写一个能稳定复现该 Bug 的测试" "Bug 修复要求复现测试(process.md)"
expect_in_file "${AGENTS}" "先写复现测试并确认它失败" "Bug 修复要求复现测试(AGENTS.md)"

# 四之三、单一入口原则必须同时活在架构模块、模板 AGENTS 与边界配置示例里
expect_in_file "${ARCHITECTURE}" "## 单一入口原则" "单一入口原则已写入架构模块"
expect_in_file "${AGENTS}" "单一入口" "单一入口原则已内联进 AGENTS.md"
expect_in_file "templates/project-template/.import-boundaries" "受保护模块路径片段" "模块边界配置示例存在"

# 四之三之二、样式禁注释与 import 排版必须同时活在分册与项目模板里
expect_in_file "skills/charles-coding-standards/languages/html-css.md" "## CSS 里不写注释" "CSS 禁注释已写入分册"
expect_in_file "skills/charles-coding-standards/stacks/vue.md" "块不写注释" "style 块禁注释已写入 Vue 分册"
expect_in_file "${AGENTS}" "样式不写注释" "CSS 禁注释已内联进 AGENTS.md"
expect_in_file "skills/charles-coding-standards/languages/javascript-typescript.md" "## import 排版" "import 排版已写入分册"
expect_in_file "${AGENTS}" "import 排版" "import 排版已内联进 AGENTS.md"
expect_in_file "skills/charles-coding-standards/rules/common.md" "## 元素与空行排版" "元素排版规则已写入通用模块"

# 四之三之三、本轮规则必须同时活在分册与项目模板里
expect_in_file "skills/charles-coding-standards/domains/testing.md" "## 测试代码位置" "测试代码位置已写入测试分册"
expect_in_file "${AGENTS}" "测试代码集中放" "测试代码位置已内联进 AGENTS.md"
expect_in_file "skills/charles-coding-standards/domains/testing.md" "必测的四类接口" "压测四类覆盖已写入测试分册"
expect_in_file "${AGENTS}" "压测必须有" "压测要求已内联进 AGENTS.md"
expect_in_file "${PROCESS}" "压测脚本" "压测已进入变更闸门表"
expect_in_file "skills/charles-coding-standards/rules/git.md" "## 提交粒度" "提交粒度已写入 Git 模块"
expect_in_file "${AGENTS}" "提交粒度" "提交粒度已内联进 AGENTS.md"
expect_in_file "${TEXT}" "禁止用 \`--\` 追加功能说明" "文件头描述粒度已写入文本模块"
expect_in_file "${AGENTS}" "禁止用 \`--\` 追加功能说明" "文件头描述粒度已内联进 AGENTS.md"
expect_in_file "skills/charles-coding-standards/stacks/vue.md" "## 常量（constants）" "常量规范已写入 Vue 分册"
expect_in_file "skills/charles-coding-standards/stacks/vue.md" "## 全局组件注册" "全局组件注册已写入 Vue 分册"
expect_in_file "${COLLABORATION}" "## 分析输出格式" "分析输出格式已写入协作模块"

# 四之三之四、规范分册的文件头不得带前缀标签(md 不进 check.sh 扫描范围,靠这条兜底)
LABEL_HITS=$(grep -rlE '^(作用|文件作用|文件用途|文件说明)[:：]' skills/ templates/ 2>/dev/null || true)

if [ -z "${LABEL_HITS}" ]; then
	pass "分册文件头无前缀标签"
else
	fail "分册文件头带了前缀标签: $(printf '%s' "${LABEL_HITS}" | tr '\n' ' ')"
fi

# 四之四、check.sh 与模板里的副本必须逐字一致
if diff -q "${CHECK_SH}" "${CHECK_SH_TEMPLATE}" >/dev/null 2>&1; then
	pass "check.sh 与模板副本一致"
else
	fail "check.sh 与模板副本不一致: ${CHECK_SH} vs ${CHECK_SH_TEMPLATE}"
fi

# 五、检查项编号：check.sh 里 [k/N] 的 N 必须统一，且 k 覆盖 1..N 不重不漏
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

# 六、文件头模板：SKILL.md / AGENTS.md 与各语言分册都必须含全角冒号的日期模板
HEADER_FILES=(
	"${SKILL}"
	"${AGENTS}"
	"skills/charles-coding-standards/languages/java.md"
	"skills/charles-coding-standards/languages/go.md"
	"skills/charles-coding-standards/languages/python.md"
	"skills/charles-coding-standards/languages/kotlin.md"
	"skills/charles-coding-standards/languages/sql.md"
	"skills/charles-coding-standards/languages/javascript-typescript.md"
	"skills/charles-coding-standards/languages/html-css.md"
	"skills/charles-coding-standards/stacks/react.md"
	"skills/charles-coding-standards/stacks/vue.md"
	"skills/charles-coding-standards/stacks/android.md"
	"skills/charles-coding-standards/stacks/nodejs.md"
	"skills/charles-coding-standards/domains/ai-ml.md"
	"${TEXT}"
	"${ARCHITECTURE}"
	"${COLLABORATION}"
)

for header_file in "${HEADER_FILES[@]}"; do
	expect_in_file "${header_file}" "创建日期：" "文件头模板(全角冒号)在 ${header_file}"
done

# 七、注释黑话词表：check.sh 里的词表(码点书写)必须逐词出现在 comments.md 的禁用词清单里
JARGON_WORDS=$(grep -m1 '^FORBIDDEN_JARGON_PATTERN=' "${CHECK_SH}" | cut -d"'" -f2 \
	| perl -CSD -pe 's/\\x\{([0-9a-f]+)\}/chr(hex($1))/ge' | tr '|' '\n')
JARGON_COUNT=$(printf '%s\n' "${JARGON_WORDS}" | grep -c . | tr -d ' ')
JARGON_MISS=""

while IFS= read -r jargon_word; do

	if [ -z "${jargon_word}" ]; then
		continue
	fi

	if ! grep -qF -- "${jargon_word}" "${TEXT}"; then
		JARGON_MISS="${JARGON_MISS} ${jargon_word}"
	fi

done <<< "${JARGON_WORDS}"

if [ "${JARGON_COUNT}" -gt 0 ] && [ -z "${JARGON_MISS}" ]; then
	pass "注释黑话词表与 text.md 同源(${JARGON_COUNT} 词)"
else
	fail "注释黑话词表与 text.md 不同源，缺失:${JARGON_MISS}"
fi

# 八、仓库自身不得含被禁字符(与 check.sh 检查一同源的三条 perl 规则)
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
