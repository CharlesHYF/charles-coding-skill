#!/usr/bin/env bash
# 验证技能同步和 Git 命令
# 创建日期：2026-11-05
# 修改日期：2026-11-05

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT
mkdir -p "${WORKDIR}/home/.agents/skills/charles-coding-bugfix" "${WORKDIR}/repo"
echo stale > "${WORKDIR}/home/.agents/skills/charles-coding-bugfix/stale"
HOME="${WORKDIR}/home" make -C "${ROOT}" sync
[ ! -e "${WORKDIR}/home/.agents/skills/charles-coding-bugfix/stale" ]
[ -f "${WORKDIR}/home/.agents/skills/charles-coding-bugfix/SKILL.md" ]
[ -f "${WORKDIR}/home/.agents/skills/charles-coding-bugfix/tools/check.sh" ]
mkdir -p "${WORKDIR}/repo/tools"
cp "${ROOT}/Makefile" "${WORKDIR}/repo/Makefile"
cp "${ROOT}/tools/git-commands.sh" "${WORKDIR}/repo/tools/git-commands.sh"
git -C "${WORKDIR}/repo" init -q -b main
cd "${WORKDIR}/repo"
make author Charles w1400214654@outlook.com
[ "$(git config user.name)" = Charles ]
echo test > file
make commit 'first commit'
[ "$(git log -1 --format=%s)" = 'first commit' ]
git switch -qc feature
echo feature >> file
git commit -qam feature
make rebase main
[ "$(git branch --show-current)" = main ]
[ "$(git log -1 --format=%s)" = feature ]
