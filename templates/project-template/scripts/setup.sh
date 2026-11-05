#!/usr/bin/env bash
# 检查基础工具并安装推送钩子
# 创建日期：2026-07-29
# 修改日期：2026-11-05

set -euo pipefail
for tool in git bash make; do
	command -v "$tool" >/dev/null || { echo "缺少工具：$tool" >&2; exit 1; }
done
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	chmod +x scripts/hooks/pre-push
	git config core.hooksPath scripts/hooks
	echo '已安装 pre-push 钩子。'
else
	echo '当前目录不是 Git 仓库，跳过钩子安装。'
fi
