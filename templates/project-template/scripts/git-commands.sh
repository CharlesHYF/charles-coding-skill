#!/usr/bin/env bash
# 执行仓库常用 Git 和技能同步操作
# 创建日期：2026-11-05
# 修改日期：2026-11-05

set -euo pipefail
COMMAND="${1:-}"
shift

case "${COMMAND}" in
	author)
		[ "$#" -eq 2 ] || { echo '用法: make author 姓名 邮箱' >&2; exit 1; }
		git config --local user.name "$1"
		git config --local user.email "$2"
		;;
	commit)
		[ "$#" -gt 0 ] || { echo '用法: make commit "提交说明"' >&2; exit 1; }
		git add -A
		git commit -m "$*"
		;;
	publish-release)
		if [ "$#" -eq 0 ] && [ -n "${VERSION:-}" ]; then
			set -- "$VERSION"
		fi
		[ "$#" -eq 1 ] && [[ "$1" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo '用法: make publish-release v1.0.0' >&2; exit 1; }
		gh workflow run release.yml --ref main -f version="$1"
		;;
	rebase)
		[ "$#" -eq 1 ] && [ "$1" = main ] || { echo '用法: make rebase main' >&2; exit 1; }
		branch="$(git symbolic-ref --quiet --short HEAD)"
		[ "${branch}" != main ] || { echo '当前已在 main 分支' >&2; exit 1; }
		[ -z "$(git status --porcelain)" ] || { echo '工作区不干净' >&2; exit 1; }
		git rebase main
		git switch main
		git merge --ff-only "${branch}"
		;;
	*) echo '未知命令' >&2; exit 1 ;;
esac
