#!/usr/bin/env bash
# 文件作用：规范校验器 -- 把 charles-coding 里的确定性规则(禁用字符/文件头/必需文件/命名)变成会 fail 的检查，交付前由 make check 强制执行，不依赖 Agent 自觉。
# 创建日期：2026-08-03
# 修改日期：2026-08-03

# 说明：故意不用 set -e。grep/perl 无匹配时返回非 0 属正常，需手动累计错误而非中断。
set -uo pipefail

# 违规计数：任意一项 > 0 则最终退出码非 0，供 CI / make check 拦截
VIOLATIONS=0

# 源码扩展名白名单：只有这些文件强制校验文件头注释块
SOURCE_EXT_REGEX='\.(java|kt|kts|go|py|js|jsx|ts|tsx|vue|sql|sh)$'

# 文本扫描排除的二进制/资源扩展名(禁用字符检查跳过这些)
BINARY_EXT_REGEX='\.(png|jpe?g|gif|webp|ico|svg|pdf|zip|gz|tar|jar|class|woff2?|ttf|eot|mp[34]|mov|lock)$'

# 必需的项目级文件清单
REQUIRED_FILES=(
	"AGENTS.md"
	"README.md"
	".gitignore"
	".editorconfig"
	".gitattributes"
)

# 打印一条违规信息并累加计数
report() {
	local message="$1"

	echo "  [FAIL] ${message}"
	VIOLATIONS=$((VIOLATIONS + 1))
}

# 列出待检查文件：优先用 git 跟踪清单，非 git 目录退回 find
list_files() {

	if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		git ls-files
	else
		find . -type f -not -path './.git/*' | sed 's|^\./||'
	fi
}

# 检查一：禁用字符(弯角引号 / 中文长破折号 / Emoji)
# 用 perl 的 \x{} 转义书写规则，确保本脚本自身不含任何被禁字符，无需自我排除
check_forbidden_chars() {
	echo "[1/4] 检查禁用字符(弯引号 / 中文破折号 / Emoji)..."

	local file
	while IFS= read -r file; do

		if [[ "${file}" =~ ${BINARY_EXT_REGEX} ]]; then
			continue
		fi

		if [ ! -f "${file}" ]; then
			continue
		fi

		# 弯角引号：U+201C U+201D U+2018 U+2019
		# 注：-CSD 让 perl 按 UTF-8 解码输入，否则多字节字符按字节读取无法匹配 \x{}
		local hits
		hits=$(perl -CSD -ne 'print "L$.: $_" if /[\x{201c}\x{201d}\x{2018}\x{2019}]/' "${file}")

		if [ -n "${hits}" ]; then
			report "${file} 含弯角引号(应改用半角 \" 或 '):"
			echo "${hits}" | sed 's/^/         /'
		fi

		# 中文长破折号：U+2014(EM DASH)，应改用半角双连字符 --
		local dash_hits
		dash_hits=$(perl -CSD -ne 'print "L$.: $_" if /\x{2014}/' "${file}")

		if [ -n "${dash_hits}" ]; then
			report "${file} 含中文长破折号(应改用半角 --):"
			echo "${dash_hits}" | sed 's/^/         /'
		fi

		# Emoji：仅匹配主要 Emoji 区段，规避 → 等合法箭头符号
		local emoji_hits
		emoji_hits=$(perl -CSD -ne 'print "L$.: $_" if /[\x{1F300}-\x{1FAFF}\x{1F1E6}-\x{1F1FF}\x{2600}-\x{27BF}\x{FE0F}]/' "${file}")

		if [ -n "${emoji_hits}" ]; then
			report "${file} 含 Emoji(应改用 SVG 或 icon 字体):"
			echo "${emoji_hits}" | sed 's/^/         /'
		fi

	done < <(list_files)
}

# 检查二：源码文件头注释块(须含"作用"与"创建日期"两个标记)
check_file_header() {
	echo "[2/4] 检查源码文件头注释块..."

	local file
	while IFS= read -r file; do

		if [[ ! "${file}" =~ ${SOURCE_EXT_REGEX} ]]; then
			continue
		fi

		if [ ! -f "${file}" ]; then
			continue
		fi

		# 只看文件前 15 行，须同时出现"作用"与"创建日期"两个标记
		local head_block
		head_block=$(head -n 15 "${file}")

		if ! echo "${head_block}" | grep -q "作用"; then
			report "${file} 文件头缺少\"文件作用\"说明"
			continue
		fi

		if ! echo "${head_block}" | grep -q "创建日期"; then
			report "${file} 文件头缺少\"创建日期\""
		fi

	done < <(list_files)
}

# 检查三：项目级必需文件是否齐全
check_required_files() {
	echo "[3/4] 检查项目必需文件..."

	local required
	for required in "${REQUIRED_FILES[@]}"; do

		if [ ! -f "${required}" ]; then
			report "缺少必需文件：${required}"
		fi
	done

	# docs/modules/ 须存在且含至少一个模块文档(README.md 之外的 .md)
	if [ ! -d "docs/modules" ]; then
		report "缺少模块文档目录：docs/modules/"
	else

		local module_doc_count
		module_doc_count=$(find docs/modules -type f -name '*.md' ! -name 'README.md' | wc -l | tr -d ' ')

		if [ "${module_doc_count}" -eq 0 ]; then
			report "docs/modules/ 下无模块文档(编码前必须先写 <模块>.md)"
		fi
	fi
}

# 检查四：数据传输命名(Java / Kotlin / TS 的响应/请求类)
# 规则：请求 XxxReqVO、响应 XxxRespVO；裸 XxxVO(非 Req/Resp)视为违规
check_naming() {
	echo "[4/4] 检查数据传输命名(XxxReqVO / XxxRespVO)..."

	local file
	while IFS= read -r file; do

		if [[ ! "${file}" =~ \.(java|kt|ts|tsx)$ ]]; then
			continue
		fi

		if [ ! -f "${file}" ]; then
			continue
		fi

		# 匹配 class / interface 定义中以 VO 结尾、但不是 ReqVO / RespVO 的类型名
		local bad_vo
		bad_vo=$(grep -nE '\b(class|interface)[[:space:]]+[A-Z][A-Za-z0-9]*VO\b' "${file}" \
			| grep -vE '(Req|Resp)VO\b' || true)

		if [ -n "${bad_vo}" ]; then
			report "${file} 存在裸 VO 命名(请求应为 XxxReqVO、响应应为 XxxRespVO):"
			echo "${bad_vo}" | sed 's/^/         /'
		fi

	done < <(list_files)
}

echo "=== charles-coding 规范校验 ==="

check_forbidden_chars
check_file_header
check_required_files
check_naming

echo "==============================="

if [ "${VIOLATIONS}" -gt 0 ]; then
	echo "[NG] 发现 ${VIOLATIONS} 处规范违规，请修正后再交付。"
	exit 1
fi

echo "[OK] 规范校验通过。"
exit 0
