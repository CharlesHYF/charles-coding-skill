#!/usr/bin/env bash
# 规范校验器 -- 把 charles-coding 里的确定性规则(禁用字符/文件头/注释语法/注释篇幅/注释黑话/必需文件/命名/模块边界/样式注释/import 排版)变成会 fail 的检查，交付前由 make verify 强制执行，不依赖 Agent 自觉
# 创建日期：2026-08-03
# 修改日期：2026-09-21

# 说明：故意不用 set -e。grep/perl 无匹配时返回非 0 属正常，需手动累计错误而非中断。
set -uo pipefail

# 违规计数：任意一项 > 0 则最终退出码非 0，供 CI / make check 拦截
VIOLATIONS=0

# 检查范围：all 扫全仓，changed 只扫本次改动(老项目接入与日常迭代用)
CHECK_MODE="all"

# 增量基线：为空时自动取与 main/master 的 merge-base
CHANGED_BASE=""

while [ $# -gt 0 ]; do

	case "$1" in
		--changed)
			CHECK_MODE="changed"
			shift

			if [ $# -gt 0 ] && [ "${1#--}" = "$1" ]; then
				CHANGED_BASE="$1"
				shift
			fi
			;;
		--all)
			CHECK_MODE="all"
			shift
			;;
		-h | --help)
			echo "用法: check.sh [--changed [base]] [--all]"
			echo "  --changed [base]  只检查本次改动的文件(base 缺省时取与 main/master 的 merge-base)"
			echo "  --all             检查全部文件(默认)"
			exit 0
			;;
		*)
			echo "[NG] 未知参数: $1"
			exit 2
			;;
	esac
done

# 文件头内容检查(半角冒号/前缀标签/单行注释误用)只扫前 80 行:足够覆盖 Java/Kotlin 在 import 后的类注释,又避开正文里 UI 字符串的误报
HEADER_SCAN_LINES=80

# 已知日期必须使用 YYYY-MM-DD，并限制月份与日期的基本范围
HEADER_DATE_REGEX='[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])'

# 源码扩展名白名单：只有这些文件强制校验文件头注释块
SOURCE_EXT_REGEX='\.(java|kt|kts|go|py|js|jsx|ts|tsx|vue|sql|sh|html|css|scss|yml|yaml|properties|toml|tf|mk)$'

# 无扩展名但属于源码的文件（按文件名匹配，与 SOURCE_EXT_REGEX 并列生效）
SOURCE_NAME_REGEX='(^|/)(Makefile|Dockerfile|Dockerfile\.[A-Za-z0-9_-]+)$'

# 样式文件：不写任何注释(含文件头)，由检查九强制
NO_COMMENT_EXT_REGEX='\.(css|scss)$'

# 豁免清单：每行一个路径片段，命中的文件跳过全部检查（用于文档反例与测试 fixture）
CHECK_IGNORE_FILE='.checkignore'

# 行级豁免标记：注释里写上它，该行跳过行匹配类检查
LINE_IGNORE_MARK='check-ignore'

# 文本扫描排除的二进制/资源扩展名(禁用字符检查跳过这些)
BINARY_EXT_REGEX='\.(png|jpe?g|gif|webp|ico|svg|pdf|zip|gz|tar|jar|class|woff2?|ttf|eot|mp[34]|mov|lock)$'

# 无意义 / 口语变量名(占位名)，见 SKILL.md "变量与函数命名规范"
MEANINGLESS_NAMES='tmp|obj|foo|baz|stuff|thing'

# 编号凑数命名(data1 / item2 之类)
NUMBERED_NAMES='(data|val|str|num|item|list|arr|res|req)[0-9]+'

# 口语函数名(说了等于没说)
PLACEHOLDER_FUNCS='doIt|doSomething|doStuff|handleStuff|processStuff|handleThing|do_it|do_something|do_stuff|handle_stuff|process_stuff'

# 必需的项目级文件清单
REQUIRED_FILES=(
	"AGENTS.md"
	"README.md"
	".gitignore"
	".editorconfig"
	".gitattributes"
)

# 判定是否为需要校验文件头的源码文件（扩展名或文件名任一命中）
is_source_file() {
	local file="$1"

	if [[ "${file}" =~ ${SOURCE_EXT_REGEX} ]]; then
		return 0
	fi

	if [[ "${file}" =~ ${SOURCE_NAME_REGEX} ]]; then
		return 0
	fi

	return 1
}

# 过滤掉带行级豁免标记的命中行
drop_ignored_lines() {
	grep -v "${LINE_IGNORE_MARK}" || true
}

# 打印一条违规信息并累加计数
report() {
	local message="$1"

	echo "  [FAIL] ${message}"
	VIOLATIONS=$((VIOLATIONS + 1))
}

# 读取 .checkignore，输出供 grep -F -f 使用的路径片段清单
ignored_patterns() {

	if [ -f "${CHECK_IGNORE_FILE}" ]; then
		grep -vE '^[[:space:]]*(#|$)' "${CHECK_IGNORE_FILE}" || true
	fi
}

# 列出全部受版本控制的文件：非 git 目录退回 find
list_all_files() {

	if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		git ls-files
	else
		find . -type f -not -path './.git/*' | sed 's|^\./||'
	fi
}

# 列出本次改动的文件：已提交的 diff + 工作区改动 + 新增未跟踪文件
list_changed_files() {
	local base="${CHANGED_BASE}"

	if [ -z "${base}" ]; then
		base=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null || true)
	fi

	if [ -z "${base}" ]; then
		echo "  [WARN] 取不到增量基线(未找到 main/master)，本次退回全量检查。" >&2
		list_all_files
		return
	fi

	{
		git diff --name-only "${base}...HEAD" 2>/dev/null || true
		git diff --name-only HEAD 2>/dev/null || true
		git ls-files --others --exclude-standard 2>/dev/null || true
	} | sort -u
}

# 列出待检查文件：按模式选择范围，再剔除 .checkignore 命中的路径
list_files() {
	local raw

	if [ "${CHECK_MODE}" = "changed" ]; then
		raw=$(list_changed_files)
	else
		raw=$(list_all_files)
	fi

	local patterns
	patterns=$(ignored_patterns)

	if [ -n "${patterns}" ]; then
		printf '%s\n' "${raw}" | grep -Fv -f <(printf '%s\n' "${patterns}") || true
	else
		printf '%s\n' "${raw}"
	fi
}

# 检查一：禁用字符(引号 / 破折号 / Emoji;含各类 Unicode 变体)
# 用 perl 的 \x{} 转义书写规则，确保本脚本自身不含任何被禁字符，无需自我排除
check_forbidden_chars() {
	echo "[1/10] 检查禁用字符(引号 / 破折号 / Emoji)..."

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
		hits=$(perl -CSD -ne 'print "L$.: $_" if /[\x{2018}\x{2019}\x{201c}\x{201d}\x{300c}-\x{300f}\x{ff02}\x{ff07}]/' "${file}" | drop_ignored_lines)

		if [ -n "${hits}" ]; then
			report "${file} 含非法引号(应改用半角 \" 或 '):"
			echo "${hits}" | sed 's/^/         /'
		fi

		# 破折号/横线类:U+2010-2015(hyphen/figure/en dash/em dash/horizontal bar)、U+2212 减号、U+FF0D 全角连字符、U+2E3A/2E3B 双三 em dash
		# 排除:ASCII -- (两个 U+002D)与目录树制表符 U+2500-257F(合法)
		local dash_hits
		dash_hits=$(perl -CSD -ne 'print "L$.: $_" if /[\x{2010}-\x{2015}\x{2212}\x{2e3a}\x{2e3b}\x{ff0d}]/' "${file}" | drop_ignored_lines)

		if [ -n "${dash_hits}" ]; then
			report "${file} 含 Unicode 破折号/横线(应改用半角 --):"
			echo "${dash_hits}" | sed 's/^/         /'
		fi

		# Emoji：仅匹配主要 Emoji 区段，规避 → 等合法箭头符号
		local emoji_hits
		emoji_hits=$(perl -CSD -ne 'print "L$.: $_" if /[\x{1F300}-\x{1FAFF}\x{1F1E6}-\x{1F1FF}\x{2600}-\x{27BF}\x{FE0F}]/' "${file}" | drop_ignored_lines)

		if [ -n "${emoji_hits}" ]; then
			report "${file} 含 Emoji(应改用 SVG 或 icon 字体):"
			echo "${emoji_hits}" | sed 's/^/         /'
		fi

	done < <(list_files)
}

# 剥离文件头日期行两侧的注释符号
normalize_header_content() {
	local content="$1"

	printf '%s' "${content}" | sed -E 's@^[[:space:]]*(/\*+|\*+/?|//+|#+|--+|<!--+|""")?[[:space:]]*@@' | sed -E 's@[[:space:]]*(\*/|-->|""")?[[:space:]]*$@@'
}

# 检查二：源码文件头注释块(作用描述行 + 创建日期 + 修改日期,冒号须为中文全角)
# 文件头首行是纯描述、不带任何前缀标签，故以"创建日期"行为锚点，回看上一行确认描述存在
check_file_header() {
	echo "[2/10] 检查源码文件头注释块..."

	local file
	while IFS= read -r file; do

		if ! is_source_file "${file}"; then
			continue
		fi

		# CSS/SCSS 不写任何注释,自然没有文件头,由检查九单独约束
		if [[ "${file}" =~ ${NO_COMMENT_EXT_REGEX} ]]; then
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
		legacy_label=$(head -n "${HEADER_SCAN_LINES}" "${file}" | perl -CSD -ne 'print "L$.: $_" if /(\x{6587}\x{4ef6}(\x{4f5c}\x{7528}|\x{7528}\x{9014}|\x{8bf4}\x{660e})|\x{4f5c}\x{7528}\x{63cf}\x{8ff0})[ \t]*[:\x{ff1a}]|^[\s*#\/<!-]*\x{4f5c}\x{7528}[ \t]*[:\x{ff1a}]/' | drop_ignored_lines)

		if [ -n "${legacy_label}" ]; then
			report "${file} 文件头带了前缀标签(首行直接写作用描述，不要标签前缀):"
			echo "${legacy_label}" | sed 's/^/         /'
		fi

		# 锚点:创建日期(全角冒号)必须存在
		local create_line create_raw create_text
		create_line=$(head -n "${HEADER_SCAN_LINES}" "${file}" | grep -nE '创建日期：' | head -1 | cut -d: -f1)

		if [ -z "${create_line}" ]; then
			report "${file} 缺少\"创建日期：\"(源码文件头注释块;若已写请确认冒号为中文全角)"
			continue
		fi

		create_raw=$(head -n "${HEADER_SCAN_LINES}" "${file}" | grep -m1 '创建日期：')
		create_text=$(normalize_header_content "${create_raw}")

		# 历史文件无法可靠确认创建日期时允许留空；已有值必须严格符合格式
		if [ "${create_text}" != "创建日期：" ] && ! printf '%s' "${create_text}" | grep -qE "^创建日期：${HEADER_DATE_REGEX}$"; then
			report "${file} 创建日期格式错误(已知日期须为 YYYY-MM-DD): ${create_text}"
		fi

		local modified_raw modified_text
		modified_raw=$(head -n "${HEADER_SCAN_LINES}" "${file}" | grep -m1 '修改日期：' || true)

		if [ -z "${modified_raw}" ]; then
			report "${file} 缺少\"修改日期：\"(源码文件头注释块;若已写请确认冒号为中文全角)"
		else
			modified_text=$(normalize_header_content "${modified_raw}")

			if ! printf '%s' "${modified_text}" | grep -qE "^修改日期：${HEADER_DATE_REGEX}$"; then
				report "${file} 修改日期格式错误(须为 YYYY-MM-DD): ${modified_text}"
			fi
		fi

		# 作用描述行:从"创建日期"往上回溯,跳过空行与 @author 等标签行,首个有实质内容的行即描述行
		local probe desc_raw desc_text
		probe=$((create_line - 1))
		desc_text=""

		while [ "${probe}" -ge 1 ]; do
			desc_raw=$(sed -n "${probe}p" "${file}")

			# 回溯到注释块起始符说明块内没有描述行,立即判缺失
			# 不这样做的话 Java/Kotlin 会一路回溯到 package/import 并把它当成描述
			if [[ "${desc_raw}" =~ ^[[:space:]]*(/\*|\<\!--|\"\"\") ]]; then
				desc_text=""
				break
			fi

			# 剥掉行首注释符号(空白 / * // # -- <!-- 三引号)与行尾收尾符号后看剩余内容
			desc_text=$(normalize_header_content "${desc_raw}")

			# package/import 等声明行与代码行不是描述,继续往上找
			if [[ "${desc_text}" =~ ^(package|import|from|use|using|require|include|#include)[[:space:]] ]] \
				|| [[ "${desc_text}" =~ [\;\{\}]$ ]]; then
				desc_text=""
				probe=$((probe - 1))
				continue
			fi

			# 空行、标签行(@author 等)、shebang 都不算描述,继续往上找
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
	echo "[3/10] 检查项目必需文件..."

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

# 检查四：命名(数据传输类命名 + 变量/函数的无意义命名)
# 规则：请求 XxxReqVO、响应 XxxRespVO；裸 XxxVO(非 Req/Resp)视为违规；tmp / obj / doIt 之类占位名一律拦截
check_naming() {
	echo "[4/10] 检查命名(XxxReqVO / XxxRespVO / 无意义命名)..."

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
			| grep -vE '((Req|Resp)VO|(Base|Abstract|Page)[A-Za-z0-9]*VO)\b' | drop_ignored_lines)

		if [ -n "${bad_vo}" ]; then
			report "${file} 存在裸 VO 命名(请求应为 XxxReqVO、响应应为 XxxRespVO):"
			echo "${bad_vo}" | sed 's/^/         /'
		fi

	done < <(list_files)

	# 无意义 / 口语命名：声明处的占位变量名、编号凑数名、口语函数名
	# 只匹配声明与赋值形态(let/const/var/val 声明、:= 、= 赋值、函数定义)，避免匹配到正常业务标识符的子串
	while IFS= read -r file; do

		if ! is_source_file "${file}"; then
			continue
		fi

		if [ ! -f "${file}" ]; then
			continue
		fi

		local bad_name
		bad_name=$(grep -nE "(\b(let|const|var|val)[[:space:]]+(${MEANINGLESS_NAMES}|${NUMBERED_NAMES})\b)|(\b(${MEANINGLESS_NAMES}|${NUMBERED_NAMES})[[:space:]]*(:=|=[^=]))|(\b(func|function|def|fun)[[:space:]]+(${PLACEHOLDER_FUNCS})\b)|(\b(${PLACEHOLDER_FUNCS})[[:space:]]*\()" "${file}" | drop_ignored_lines)

		if [ -n "${bad_name}" ]; then
			report "${file} 存在无意义/口语命名(改成见名知义的业务命名，动词按 SKILL.md 动作词表统一):"
			echo "${bad_name}" | sed 's/^/         /'
		fi

	done < <(list_files)
}

# 检查五：注释语法(多行注释必须用块/文档注释，禁止连续 // 或 # 拼多行)
# 只做确定性检查，规避误报：文件头注释语法、块注释挤行、Python docstring 三段式与引号
check_comment_syntax() {
	echo "[5/10] 检查注释语法(块注释 / docstring)..."

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

# 抽取文件里的注释行(块注释 / docstring / 行注释 / 行尾 // 注释)，输出 "行号<TAB>原文"
# 只取注释，避免把业务字符串(如商品名里的正常词)误判为黑话
# 行注释符按语言区分：# 只在 Python / Shell 算注释，-- 只在 SQL 算注释
# 否则 CSS 自定义属性(--bg: #fff)、JS 自减(--count)会被当成注释行
# 行尾注释只取 // 之后的部分，且跳过 https:// 这类 URL，避免把代码行当注释
extract_comment_lines() {
	local file="$1"
	local allow_hash=0
	local allow_dash=0
	local allow_doc=0

	case "${file}" in
		*.py)
			allow_hash=1
			allow_doc=1
			;;
		*.sh | *.yml | *.yaml | *.properties | *.toml | *.tf | *.mk | Makefile | */Makefile | Dockerfile | */Dockerfile | Dockerfile.* | */Dockerfile.*)
			allow_hash=1
			;;
		*.sql)
			allow_dash=1
			;;
	esac

	awk -v allow_hash="${allow_hash}" -v allow_dash="${allow_dash}" -v allow_doc="${allow_doc}" '
		function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
		{
			line = trim($0)

			if (inblk) { print NR "\t" $0; if (line ~ /\*\//) { inblk = 0 }; next }
			if (inhtml) { print NR "\t" $0; if (line ~ /-->/) { inhtml = 0 }; next }
			if (indoc) { if (line ~ /"""/) { indoc = 0; next } print NR "\t" $0; next }
			if (line ~ /^\/\*/) { print NR "\t" $0; if (line !~ /\*\//) { inblk = 1 }; next }
			if (line ~ /^<!--/) { print NR "\t" $0; if (line !~ /-->/) { inhtml = 1 }; next }
			if (allow_doc && line == "\"\"\"") { indoc = 1; next }
			if (allow_hash && line ~ /^#/) { print NR "\t" $0; next }
			if (allow_dash && line ~ /^--/) { print NR "\t" $0; next }
			if (line ~ /^\/\//) { print NR "\t" $0; next }

			# 行尾注释:只取 // 之后的内容,且 // 前一字符是冒号时跳过(那是 https:// 这类 URL)
			slash = index(line, "//")

			if (slash > 1 && substr(line, slash - 1, 1) != ":") { print NR "\t" substr(line, slash); next }
		}
	' "${file}"
}

# 注释块正文行数上限：超过即视为"长篇大论"，背景推演/方案权衡应写进 docs/modules/
MAX_COMMENT_BODY_LINES=3

# 检查六：注释篇幅(正文默认 1-2 行,硬上限 MAX_COMMENT_BODY_LINES 行)与句子折断
# 标签行(@param / @return / :param 等)不计入正文,避免多参数 Javadoc 误报
# 折断判定走 perl -CSD:中文标点是多字节,awk 在非 UTF-8 locale 下按字节比对会误命中
check_comment_length() {
	echo "[6/10] 检查注释篇幅与折行(正文不超过 ${MAX_COMMENT_BODY_LINES} 行,不许句子折断)..."

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

		# 句子折断:注释正文行以逗号 / 顿号 / 中文分号收尾,说明一句话没写完就换行
		local broken
		broken=$(extract_comment_lines "${file}" | perl -CSD -ne 'chomp; my ($num, $text) = split(/\t/, $_, 2); next unless defined $text; $text =~ s/^\s+//; $text =~ s/^\s*(\/\*+|\*+\/?|\/\/+|\#+|--+|<!--+)\s*//; $text =~ s/\s*(\*\/|-->)\s*$//; $text =~ s/\s+$//; print "L$num: $text\n" if $text =~ /[\x{ff0c}\x{002c}\x{3001}\x{ff1b}]$/' | drop_ignored_lines)

		if [ -n "${broken}" ]; then
			report "${file} 注释正文句子被折断(一条注释一行写完,写不下就删减而不是折行):"
			echo "${broken}" | sed 's/^/         /'
		fi

	done < <(list_files)
}

# 注释黑话词表：AI 味隐喻/口语表达，一律改写为工程动作词(获取 / 组装 / 校验 / 降级 等)
# 用 perl \x{} 码点书写规则，确保本脚本自身不含这些字面量，无需自我排除；词表与 reference/comments.md 同源
FORBIDDEN_JARGON_PATTERN='\x{4fe1}\x{5c01}|\x{76d2}\x{5b50}|\x{585e}\x{8fdb}|\x{585e}\x{7ed9}|\x{62c6}\x{51fa}|\x{538b}\x{6210}|\x{7ffb}\x{8868}|\x{7ffb}\x{5bf9}\x{8d26}\x{8868}|\x{5582}\x{7ed9}|\x{5410}\x{51fa}|\x{642c}\x{8fd0}|\x{62ff}\x{51fa}\x{6765}|\x{7559}\x{7ed9}\x{4e0b}\x{6e38}|\x{5b9e}\x{6293}\x{7ec8}\x{503c}|\x{62fc}\x{8d77}\x{6765}|\x{704c}\x{8fdb}\x{53bb}|\x{5f62}\x{72b6}\x{4e0d}\x{7b26}|\x{6536}\x{53e3}|\x{6253}\x{5e73}|\x{644a}\x{5e73}'

# 检查七：注释黑话(隐喻 / 口语表达)，词表见上方 FORBIDDEN_JARGON_PATTERN，一律改写为工程动作词
check_comment_jargon() {
	echo "[7/10] 检查注释黑话(隐喻 / 口语表达)..."

	local file
	while IFS= read -r file; do

		if ! is_source_file "${file}"; then
			continue
		fi

		if [ ! -f "${file}" ]; then
			continue
		fi

		local hits
		hits=$(extract_comment_lines "${file}" | JARGON="${FORBIDDEN_JARGON_PATTERN}" perl -CSD -ne 'BEGIN { $re = qr/$ENV{JARGON}/ } if (/$re/) { s/^(\d+)\t/L$1: /; print }' | drop_ignored_lines)

		if [ -n "${hits}" ]; then
			report "${file} 注释含隐喻/口语表达(改用工程动作词：获取 / 组装 / 校验 / 降级 等，词表见 comments.md):"
			echo "${hits}" | sed 's/^/         /'
		fi

	done < <(list_files)
}

# 模块访问边界配置：每行 "受保护模块路径片段 | 允许引用它的文件路径片段(逗号分隔)"
IMPORT_BOUNDARY_FILE='.import-boundaries'

# 检查八：模块访问边界(单一入口原则,禁止绕过入口直接引用底层实现)
# 受保护片段里的 / 同时按 . 匹配,以覆盖 Java 的 import com.xx.dal.mapper 这类写法
check_import_boundaries() {
	echo "[8/10] 检查模块访问边界(单一入口)..."

	if [ ! -f "${IMPORT_BOUNDARY_FILE}" ]; then
		echo "  [SKIP] 未配置 ${IMPORT_BOUNDARY_FILE}，跳过。"
		return
	fi

	local rule
	while IFS= read -r rule || [ -n "${rule}" ]; do

		case "${rule}" in
			'' | '#'*)
				continue
				;;
		esac

		local protected allowed protected_regex
		protected=$(printf '%s' "${rule}" | cut -d'|' -f1 | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')
		allowed=$(printf '%s' "${rule}" | cut -d'|' -f2 | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')

		if [ -z "${protected}" ]; then
			continue
		fi

		# 路径分隔符按 / 或 . 匹配，兼容 Java 包名写法
		protected_regex=$(printf '%s' "${protected}" | sed 's@/@[./]@g')

		local file
		while IFS= read -r file; do

			if ! is_source_file "${file}"; then
				continue
			fi

			if [ ! -f "${file}" ]; then
				continue
			fi

			# 受保护模块自身不算违规
			if [[ "${file}" =~ ${protected_regex} ]]; then
				continue
			fi

			# 白名单内的引用方不算违规
			local permitted=0
			local pattern
			local rest="${allowed}"

			while [ -n "${rest}" ]; do
				pattern="${rest%%,*}"

				if [ "${pattern}" = "${rest}" ]; then
					rest=""
				else
					rest="${rest#*,}"
				fi

				pattern=$(printf '%s' "${pattern}" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')

				if [ -n "${pattern}" ] && [[ "${file}" =~ ${pattern} ]]; then
					permitted=1
					break
				fi
			done

			if [ "${permitted}" = "1" ]; then
				continue
			fi

			local hits
			hits=$(grep -nE "^[[:space:]]*(import|from|const|let|var|using|require)[^\"']*[\"'][^\"']*${protected_regex}|^[[:space:]]*import[[:space:]]+[A-Za-z0-9_.]*${protected_regex}" "${file}" | drop_ignored_lines)

			if [ -n "${hits}" ]; then
				report "${file} 绕过入口直接引用受保护模块 ${protected}(应改为经由: ${allowed}):"
				echo "${hits}" | sed 's/^/         /'
			fi

		done < <(list_files)

	done < "${IMPORT_BOUNDARY_FILE}"
}

# 检查九：样式里不写注释(CSS / SCSS 文件与 Vue SFC 的 style 块)
# 样式意图由 class 名与自定义属性命名表达，设计决策写进模块文档
check_style_comments() {
	echo "[9/10] 检查样式注释(CSS 与 style 块不写注释)..."

	local file
	while IFS= read -r file; do

		if [ ! -f "${file}" ]; then
			continue
		fi

		local hits=""

		if [[ "${file}" =~ ${NO_COMMENT_EXT_REGEX} ]]; then
			# 块注释任意位置即违规;行首 // 是 SCSS 单行注释,URL 里的 // 不在行首故不误伤
			hits=$(grep -nE '/\*|^[[:space:]]*//' "${file}" | drop_ignored_lines)
		elif [[ "${file}" =~ \.(vue|html)$ ]]; then
			# 只看 style 块内部,模板与脚本的注释不受这条约束
			hits=$(awk '
				/<style/ { instyle = 1; next }
				/<\/style>/ { instyle = 0; next }
				instyle && (/\/\*/ || /^[[:space:]]*\/\//) { print NR ": " $0 }
			' "${file}" | drop_ignored_lines)
		else
			continue
		fi

		if [ -n "${hits}" ]; then
			report "${file} 样式里写了注释(CSS 与 style 块不写任何注释,含文件头):"
			echo "${hits}" | sed 's/^/         /'
		fi

	done < <(list_files)
}

# 检查十：import 排版(type import 不得出现在值 import 之前)
# 顺序固定为值 import -> type import -> 常量,便于一眼看清依赖来源
check_import_order() {
	echo "[10/10] 检查 import 排版(type 在值 import 之后)..."

	local file
	while IFS= read -r file; do

		if [[ ! "${file}" =~ \.(ts|tsx|js|jsx|vue)$ ]]; then
			continue
		fi

		if [ ! -f "${file}" ]; then
			continue
		fi

		local first_type last_value
		first_type=$(grep -nE '^[[:space:]]*import[[:space:]]+type[[:space:]]' "${file}" | head -1 | cut -d: -f1)
		last_value=$(grep -nE '^[[:space:]]*import[[:space:]]' "${file}" \
			| grep -vE '^[0-9]+:[[:space:]]*import[[:space:]]+type[[:space:]]' \
			| tail -1 | cut -d: -f1)

		if [ -z "${first_type}" ] || [ -z "${last_value}" ]; then
			continue
		fi

		if [ "${first_type}" -lt "${last_value}" ]; then
			report "${file} import 排版错误(L${first_type} 的 type import 在 L${last_value} 的值 import 之前,type 应排在全部值 import 之后)"
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
check_comment_jargon
check_import_boundaries
check_style_comments
check_import_order

echo "==============================="

if [ "${VIOLATIONS}" -gt 0 ]; then
	echo "[NG] 发现 ${VIOLATIONS} 处规范违规，请修正后再交付。"
	exit 1
fi

echo "[OK] 规范校验通过。"
exit 0
