#!/usr/bin/env bash
# 规范校验器 -- 把 charles-coding 里的确定性规则(禁用字符/文件头/注释语法/注释篇幅/必需文件/命名)变成会 fail 的检查，交付前由 make check 强制执行，不依赖 Agent 自觉
# 创建日期：2026-08-03
# 修改日期：2026-08-31

# 说明：故意不用 set -e。grep/perl 无匹配时返回非 0 属正常，需手动累计错误而非中断。
set -uo pipefail

# 违规计数：任意一项 > 0 则最终退出码非 0，供 CI / make check 拦截
VIOLATIONS=0

# 文件头内容检查(半角冒号/前缀标签/单行注释误用)只扫前 80 行:足够覆盖 Java/Kotlin 在 import 后的类注释,又避开正文里 UI 字符串的误报
HEADER_SCAN_LINES=80

# 源码扩展名白名单：只有这些文件强制校验文件头注释块
SOURCE_EXT_REGEX='\.(java|kt|kts|go|py|js|jsx|ts|tsx|vue|sql|sh|html|css|scss)$'

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

# 检查一：禁用字符(引号 / 破折号 / Emoji;含各类 Unicode 变体)
# 用 perl 的 \x{} 转义书写规则，确保本脚本自身不含任何被禁字符，无需自我排除
check_forbidden_chars() {
	echo "[1/6] 检查禁用字符(引号 / 破折号 / Emoji)..."

	local file
	while IFS= read -r file; do

		if [[ "${file}" =~ ${BINARY_EXT_REGEX} ]]; then
			continue
		fi

		if [ ! -f "${file}" ]; then
			continue
		fi

		# 引号类:弯引号 U+2018/2019/201C/201D、CJK 角引号 U+300C-300F、全角引号 U+FF02/FF07
		# 排除:ASCII " ' 与书名号 U+300A/300B(合法);本行用 \x{} 转义,check.sh 自身不含被禁字符
		# 注：-CSD 让 perl 按 UTF-8 解码输入，否则多字节字符按字节读取无法匹配 \x{}
		local hits
		hits=$(perl -CSD -ne 'print "L$.: $_" if /[\x{2018}\x{2019}\x{201c}\x{201d}\x{300c}-\x{300f}\x{ff02}\x{ff07}]/' "${file}")

		if [ -n "${hits}" ]; then
			report "${file} 含非法引号(应改用半角 \" 或 '):"
			echo "${hits}" | sed 's/^/         /'
		fi

		# 破折号/横线类:U+2010-2015(hyphen/figure/en dash/em dash/horizontal bar)、U+2212 减号、U+FF0D 全角连字符、U+2E3A/2E3B 双三 em dash
		# 排除:ASCII -- (两个 U+002D)与目录树制表符 U+2500-257F(合法)
		local dash_hits
		dash_hits=$(perl -CSD -ne 'print "L$.: $_" if /[\x{2010}-\x{2015}\x{2212}\x{2e3a}\x{2e3b}\x{ff0d}]/' "${file}")

		if [ -n "${dash_hits}" ]; then
			report "${file} 含 Unicode 破折号/横线(应改用半角 --):"
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

# 检查二：源码文件头注释块(作用描述行 + 创建日期 + 修改日期,冒号须为中文全角)
# 文件头首行是纯描述、不带任何前缀标签，故以"创建日期"行为锚点，回看上一行确认描述存在
check_file_header() {
	echo "[2/6] 检查源码文件头注释块..."

	local file
	while IFS= read -r file; do

		if [[ ! "${file}" =~ ${SOURCE_EXT_REGEX} ]]; then
			continue
		fi

		if [ ! -f "${file}" ]; then
			continue
		fi

		# 半角冒号:创建/修改日期必须用中文全角冒号
		local halfwidth
		halfwidth=$(head -n "${HEADER_SCAN_LINES}" "${file}" | grep -nE '(创建日期|修改日期)[[:space:]]*:' || true)

		if [ -n "${halfwidth}" ]; then
			report "${file} 日期行用了半角冒号(须改为中文全角冒号):"
			echo "${halfwidth}" | sed 's/^/         /'
		fi

		# 残留前缀标签:文件头首行须是纯描述,不得写标签前缀(如 U+6587 U+4EF6 U+4F5C U+7528 加冒号)
		# 用 perl \x{} 码点书写规则,确保 check.sh 自身不含该字面量,无需自我排除
		local legacy_label
		legacy_label=$(head -n "${HEADER_SCAN_LINES}" "${file}" | perl -CSD -ne 'print "L$.: $_" if /(\x{6587}\x{4ef6}(\x{4f5c}\x{7528}|\x{7528}\x{9014}|\x{8bf4}\x{660e})|\x{4f5c}\x{7528}\x{63cf}\x{8ff0})[ \t]*[:\x{ff1a}]/')

		if [ -n "${legacy_label}" ]; then
			report "${file} 文件头带了前缀标签(首行直接写作用描述，不要标签前缀):"
			echo "${legacy_label}" | sed 's/^/         /'
		fi

		# 锚点:创建日期(全角冒号)必须存在
		local create_line
		create_line=$(grep -nE '创建日期：' "${file}" | head -1 | cut -d: -f1)

		if [ -z "${create_line}" ]; then
			report "${file} 缺少\"创建日期：\"(源码文件头注释块;若已写请确认冒号为中文全角)"
			continue
		fi

		if ! grep -qE '修改日期：' "${file}"; then
			report "${file} 缺少\"修改日期：\"(源码文件头注释块;若已写请确认冒号为中文全角)"
		fi

		# 作用描述行:从"创建日期"往上回溯,跳过空行与 @author 等标签行,首个有实质内容的行即描述行
		local probe desc_raw desc_text
		probe=$((create_line - 1))
		desc_text=""

		while [ "${probe}" -ge 1 ]; do
			desc_raw=$(sed -n "${probe}p" "${file}")
			# 剥掉行首注释符号(空白 / * // # -- <!-- 三引号)与行尾收尾符号后看剩余内容
			desc_text=$(printf '%s' "${desc_raw}" | sed -E 's@^[[:space:]]*(/\*+|\*+/?|//+|#+|--+|<!--+|""")?[[:space:]]*@@' | sed -E 's@[[:space:]]*(\*/|-->)?[[:space:]]*$@@')

			# 空行、标签行(@author 等)、注释块起始符、shebang 都不算描述,继续往上找
			if [ -n "${desc_text}" ] && [[ ! "${desc_text}" =~ ^@ ]] && [[ ! "${desc_text}" =~ ^!/ ]]; then
				break
			fi

			desc_text=""
			probe=$((probe - 1))
		done

		if [ -z "${desc_text}" ]; then
			report "${file} 缺少文件头作用描述行(\"创建日期：\"上方应有一到两句话的作用描述)"
			continue
		fi

		# 描述行句尾不加句号
		if printf '%s' "${desc_text}" | grep -qE '[。.]$'; then
			report "${file} 文件头作用描述行结尾带了句号(须去掉): ${desc_text}"
		fi

	done < <(list_files)
}

# 检查三：项目级必需文件是否齐全
check_required_files() {
	echo "[3/6] 检查项目必需文件..."

	local required
	for required in "${REQUIRED_FILES[@]}"; do

		if [ ! -f "${required}" ]; then
			report "缺少必需文件：${required}"
		fi
	done

	# docs/modules/ 须存在,且模块文档必须在系统模块子目录下(两级:docs/modules/<系统模块>/<模块>.md)
	if [ ! -d "docs/modules" ]; then
		report "缺少模块文档目录：docs/modules/"
	else

		# 一级违规:直接躺在 docs/modules/ 根的 .md(README.md 除外)
		local module_flat
		module_flat=$(find docs/modules -maxdepth 1 -type f -name '*.md' ! -name 'README.md')

		if [ -n "${module_flat}" ]; then
			report "docs/modules/ 下有一级模块文档(须放进系统模块子目录 docs/modules/<系统模块>/x.md):"
			echo "${module_flat}" | sed 's/^/         /'
		fi

		# 至少一个合规的两级模块文档
		local module_doc_count
		module_doc_count=$(find docs/modules -mindepth 2 -type f -name '*.md' ! -name 'README.md' | wc -l | tr -d ' ')

		if [ "${module_doc_count}" -eq 0 ]; then
			report "docs/modules/ 下无模块文档(编码前必须先写 docs/modules/<系统模块>/<模块>.md)"
		fi
	fi

	# test_cases/ 须存在,且用例必须在两级子目录下(test_cases/<系统模块>/<测试类型>/x.md)
	if [ ! -d "test_cases" ]; then
		report "缺少测试用例目录：test_cases/(交付必须附带测试用例)"
	else

		# 浅层违规:躺在 test_cases/ 根或仅一层子目录里的 .md(README.md 除外)
		local case_flat
		case_flat=$(find test_cases -maxdepth 2 -type f -name '*.md' ! -name 'README.md')

		if [ -n "${case_flat}" ]; then
			report "test_cases/ 下有浅层用例文档(须放进 test_cases/<系统模块>/<类型>/x.md):"
			echo "${case_flat}" | sed 's/^/         /'
		fi

		# 至少一个合规的用例文档(位于 <系统模块>/<类型>/ 下)
		local case_doc_count
		case_doc_count=$(find test_cases -mindepth 3 -type f -name '*.md' ! -name 'README.md' | wc -l | tr -d ' ')

		if [ "${case_doc_count}" -eq 0 ]; then
			report "test_cases/ 下无用例文档(交付必须附带 test_cases/<系统模块>/<类型>/x.md)"
		fi
	fi
}

# 检查四：数据传输命名(Java / Kotlin / TS 的响应/请求类)
# 规则：请求 XxxReqVO、响应 XxxRespVO；裸 XxxVO(非 Req/Resp)视为违规
check_naming() {
	echo "[4/6] 检查数据传输命名(XxxReqVO / XxxRespVO)..."

	local file
	while IFS= read -r file; do

		if [[ ! "${file}" =~ \.(java|kt|ts|tsx|vue)$ ]]; then
			continue
		fi

		if [ ! -f "${file}" ]; then
			continue
		fi

		# 匹配 class / interface / type 定义中以 VO 结尾、但不是 ReqVO / RespVO 的类型名
		# 排除框架基类 BaseVO / AbstractXxxVO / PageXxxVO 等,避免误报
		local bad_vo
		bad_vo=$(grep -nE '\b(class|interface|type)[[:space:]]+[A-Z][A-Za-z0-9]*VO\b' "${file}" \
			| grep -vE '((Req|Resp)VO|(Base|Abstract|Page)[A-Za-z0-9]*VO)\b' || true)

		if [ -n "${bad_vo}" ]; then
			report "${file} 存在裸 VO 命名(请求应为 XxxReqVO、响应应为 XxxRespVO):"
			echo "${bad_vo}" | sed 's/^/         /'
		fi

	done < <(list_files)
}

# 检查五：注释语法(多行注释必须用块/文档注释，禁止连续 // 或 # 拼多行)
# 只做确定性检查，规避误报：文件头注释语法、块注释挤行、Python docstring 三段式与引号
check_comment_syntax() {
	echo "[5/6] 检查注释语法(块注释 / docstring)..."

	local file
	while IFS= read -r file; do

		if [ ! -f "${file}" ]; then
			continue
		fi

		# 一、C 系语言(含 Go/Vue/CSS)：文件头不得用 // 起头，必须用块注释
		# Go 的声明级注释用 // 是标准写法，但文件头仍须 /* */,故一并纳入(只匹配含"创建日期"的行)
		if [[ "${file}" =~ \.(java|kt|kts|go|js|jsx|ts|tsx|vue|css|scss)$ ]]; then
			local slash_header
			slash_header=$(head -n "${HEADER_SCAN_LINES}" "${file}" | grep -nE '^[[:space:]]*//.*创建日期：' || true)

			if [ -n "${slash_header}" ]; then
				report "${file} 文件头用了 // 单行注释(须改为块注释三段式；Go 用 /* */,其余用 /** */):"
				echo "${slash_header}" | sed 's/^/         /'
			fi
		fi

		# 二、C 系语言 + Go：/** 与正文挤在同一行(块注释须三段式：/** 独占首行、* 正文、*/ 独占末行)
		if [[ "${file}" =~ \.(java|kt|kts|go|js|jsx|ts|tsx|vue|css|scss)$ ]]; then
			local inline_block
			inline_block=$(grep -nE '/\*\*[^*/].*\*/' "${file}" || true)

			if [ -n "${inline_block}" ]; then
				report "${file} 块注释挤在一行(/** 须独占首行，*/ 须独占末行):"
				echo "${inline_block}" | sed 's/^/         /'
			fi
		fi

		# 三、Python：文件头须用 docstring,不得用 # 写(# -*- coding -*- 除外)
		if [[ "${file}" =~ \.py$ ]]; then
			local hash_header
			hash_header=$(head -n "${HEADER_SCAN_LINES}" "${file}" | grep -nE '^[[:space:]]*#.*创建日期：' || true)

			if [ -n "${hash_header}" ]; then
				report "${file} 文件头用了 # 单行注释(须改为 \"\"\" docstring 三段式):"
				echo "${hash_header}" | sed 's/^/         /'
			fi

			# 四、Python：docstring 起始行不得带正文(含单行 \"\"\"摘要\"\"\" 与悬空字符串)
			local inline_doc
			inline_doc=$(grep -nE '^[[:space:]]*"""..*' "${file}" || true)

			if [ -n "${inline_doc}" ]; then
				report "${file} docstring 未三段式(\"\"\" 须独占首行、正文另起一行顶格、\"\"\" 独占末行):"
				echo "${inline_doc}" | sed 's/^/         /'
			fi

			# 五、Python：docstring 统一双引号,禁止单引号三引号(PEP 257 / Ruff D300)
			local single_doc
			single_doc=$(grep -nE "^[[:space:]]*'''" "${file}" || true)

			if [ -n "${single_doc}" ]; then
				report "${file} 用了单引号三引号 docstring(须统一为 \"\"\"):"
				echo "${single_doc}" | sed 's/^/         /'
			fi
		fi

	done < <(list_files)
}

# 注释块正文行数上限：超过即视为"长篇大论"，背景推演/方案权衡应写进 docs/modules/
MAX_COMMENT_BODY_LINES=3

# 检查六：注释篇幅(正文默认 1-2 行,硬上限 MAX_COMMENT_BODY_LINES 行)
# 标签行(@param / @return / :param 等)不计入正文,避免多参数 Javadoc 误报
check_comment_length() {
	echo "[6/6] 检查注释篇幅(正文不超过 ${MAX_COMMENT_BODY_LINES} 行)..."

	local file
	while IFS= read -r file; do

		if [ ! -f "${file}" ]; then
			continue
		fi

		# C 系语言:/* */ 块注释,以及连续 // 注释行(Go doc 用 // 是标准,其余语言本就不该用 // 拼多行)
		if [[ "${file}" =~ \.(java|kt|kts|go|js|jsx|ts|tsx|vue|css|scss)$ ]]; then
			local long_block
			long_block=$(awk -v max="${MAX_COMMENT_BODY_LINES}" '
				function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
				{
					line = trim($0)
					if (inblk) {
						if (line ~ /\*\//) { inblk = 0; if (n > max) { print start "\t" n }; next }
						body = line; sub(/^\*+[ \t]*/, "", body); body = trim(body)
						if (body != "" && body !~ /^@/) { n++ }
						next
					}
					if (line ~ /^\/\*/ && line !~ /\*\//) { inblk = 1; n = 0; start = NR; next }
					if (line ~ /^\/\//) {
						if (!inrun) { inrun = 1; rn = 0; rstart = NR }
						body = line; sub(/^\/\/+[ \t]*/, "", body); body = trim(body)
						if (body != "" && body !~ /^@/) { rn++ }
						next
					}
					if (inrun) { if (rn > max) { print rstart "\t" rn }; inrun = 0 }
				}
				END { if (inrun && rn > max) { print rstart "\t" rn } }
			' "${file}")

			if [ -n "${long_block}" ]; then
				report "${file} 注释块正文超过 ${MAX_COMMENT_BODY_LINES} 行(行号:正文行数;背景推演/方案权衡请写进 docs/modules/):"
				echo "${long_block}" | awk '{ print "         L" $1 ": " $2 " 行正文" }'
			fi
		fi

		# Python:三段式 docstring(""" 独占一行开头);非三段式的由检查五单独拦截
		if [[ "${file}" =~ \.py$ ]]; then
			local long_doc
			long_doc=$(awk -v max="${MAX_COMMENT_BODY_LINES}" '
				function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
				{
					line = trim($0)
					if (indoc) {
						if (line ~ /"""/) { indoc = 0; if (n > max) { print start "\t" n }; next }
						if (line != "" && line !~ /^(@|:param|:return|:raise)/) { n++ }
						next
					}
					if (line == "\"\"\"") { indoc = 1; n = 0; start = NR }
				}
			' "${file}")

			if [ -n "${long_doc}" ]; then
				report "${file} docstring 正文超过 ${MAX_COMMENT_BODY_LINES} 行(行号:正文行数;背景推演/方案权衡请写进 docs/modules/):"
				echo "${long_doc}" | awk '{ print "         L" $1 ": " $2 " 行正文" }'
			fi
		fi

	done < <(list_files)
}

echo "=== charles-coding 规范校验 ==="

check_forbidden_chars
check_file_header
check_required_files
check_naming
check_comment_syntax
check_comment_length

echo "==============================="

if [ "${VIOLATIONS}" -gt 0 ]; then
	echo "[NG] 发现 ${VIOLATIONS} 处规范违规，请修正后再交付。"
	exit 1
fi

echo "[OK] 规范校验通过。"
exit 0
