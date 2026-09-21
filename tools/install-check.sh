#!/usr/bin/env bash
# 规范校验器安装器
# 创建日期：2026-09-21
# 修改日期：2026-09-21

set -uo pipefail

SKILL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# 目标项目路径：缺省为当前目录
TARGET="${1:-.}"

if [ ! -d "${TARGET}" ]; then
	echo "[NG] 目标目录不存在: ${TARGET}"
	exit 1
fi

TARGET="$(cd "${TARGET}" && pwd)"
echo "=== 安装 charles-coding 规范校验器 -> ${TARGET} ==="

mkdir -p "${TARGET}/scripts/hooks"

# 校验器本体：已存在则覆盖，保持与 skill 同版本
cp "${SKILL_ROOT}/tools/check.sh" "${TARGET}/scripts/check.sh"
chmod +x "${TARGET}/scripts/check.sh"
echo "  [OK] scripts/check.sh"

# pre-push 钩子：推 main 跑全量，推其它分支跑增量
cp "${SKILL_ROOT}/templates/project-template/scripts/hooks/pre-push" "${TARGET}/scripts/hooks/pre-push"
chmod +x "${TARGET}/scripts/hooks/pre-push"
echo "  [OK] scripts/hooks/pre-push"

# 豁免清单：首次安装才写，不覆盖项目已有配置
if [ ! -f "${TARGET}/.checkignore" ]; then
	cat > "${TARGET}/.checkignore" <<'IGNORE'
# 每行一个路径片段，命中的文件跳过全部规范检查
# 用于文档里的反例、测试 fixture、第三方拷贝进来的代码
IGNORE
	echo "  [OK] .checkignore（已创建空清单）"
fi

# 模块访问边界：首次安装才写
if [ ! -f "${TARGET}/.import-boundaries" ]; then
	cp "${SKILL_ROOT}/templates/project-template/.import-boundaries" "${TARGET}/.import-boundaries"
	echo "  [OK] .import-boundaries（已创建示例，按项目实际填写）"
fi

# make 目标：已有 Makefile 只在缺失时追加
if [ ! -f "${TARGET}/Makefile" ]; then
	cat > "${TARGET}/Makefile" <<'MK'
# 项目命令入口 -- 提供规范校验与测试的统一目标
# 创建日期：2026-09-21
# 修改日期：2026-09-21

.PHONY: lint lint-all verify verify-all check

lint: ## 规范校验（只查本次改动）
	bash scripts/check.sh --changed

lint-all: ## 规范校验（全量）
	bash scripts/check.sh --all

check: ## 运行测试
	bash scripts/test.sh

verify: ## 交付闸门（增量规范校验 + 测试）
	bash scripts/check.sh --changed
	bash scripts/test.sh

verify-all: ## 全量闸门（全量规范校验 + 测试）
	bash scripts/check.sh --all
	bash scripts/test.sh
MK
	echo "  [OK] Makefile（已创建）"
elif ! grep -q '^verify:' "${TARGET}/Makefile"; then
	cat >> "${TARGET}/Makefile" <<'MK'

.PHONY: lint lint-all verify verify-all

lint: ## 规范校验（只查本次改动）
	bash scripts/check.sh --changed

lint-all: ## 规范校验（全量）
	bash scripts/check.sh --all

verify: ## 交付闸门（增量规范校验 + 测试）
	bash scripts/check.sh --changed
	bash scripts/test.sh

verify-all: ## 全量闸门（全量规范校验 + 测试）
	bash scripts/check.sh --all
	bash scripts/test.sh
MK
	echo "  [OK] Makefile（已追加 lint/verify 目标）"
else
	echo "  [SKIP] Makefile 已有 verify 目标，未改动"
fi

# 钩子路径：只对 git 仓库配置
if git -C "${TARGET}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	git -C "${TARGET}" config core.hooksPath scripts/hooks
	echo "  [OK] git config core.hooksPath = scripts/hooks"
else
	echo "  [WARN] ${TARGET} 不是 git 仓库，跳过钩子安装"
fi

echo "==============================="
echo "[OK] 安装完成。下一步："
echo "  1. bash scripts/check.sh --all > baseline.txt   记录存量违规基线"
echo "  2. make verify                                  确认增量闸门可用"
echo "  3. 按项目实际填写 .import-boundaries 与 .checkignore"
