#!/usr/bin/env bash
# 验证脚手架的备份、安装与命令入口
# 创建日期：2026-11-05
# 修改日期：2026-11-05

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/project" "$WORK/home" "$WORK/target/data" "$WORK/target/deploy"
cp -R "$ROOT/templates/project-template/." "$WORK/project/"
cd "$WORK/project"
export HOME="$WORK/home"
printf 'original\n' > app.txt
mkdir -p data deploy
printf 'protected\n' > data/item
printf 'secret\n' > deploy/.env.prod
make backup VERSION=v1.3.0 PROJECT_NAME=demo
make backup VERSION=v1.3.0 PROJECT_NAME=demo
DAY="$(date +%Y%m%d)"
BACKUP="$HOME/Documents/demo/backup/demo-backup-$DAY-v1.3.0.zip"
[ -f "$BACKUP" ]
[ -f "$HOME/Documents/demo/backup/demo-backup-$DAY-v1.3.0(2).zip" ]
make backup-data "$WORK/custom" VERSION=v1.3.0 PROJECT_NAME=demo
[ -f "$WORK/custom/demo-backup-data-$DAY-v1.3.0.zip" ]
make backup-db "$WORK/custom" VERSION=v1.3.0 PROJECT_NAME=demo DB_BACKUP_COMMAND='printf database'
[ -f "$WORK/custom/demo-backup-db-$DAY-v1.3.0.zip" ]
printf 'old\n' > "$WORK/target/app.txt"
printf 'old data\n' > "$WORK/target/data/item"
printf 'old secret\n' > "$WORK/target/deploy/.env.prod"
make install-package "$BACKUP" PROJECT_NAME=demo PROJECT_DIR="$WORK/target"
[ "$(cat "$WORK/target/app.txt")" = old ]
make install-package "$BACKUP" PROJECT_NAME=demo PROJECT_DIR="$WORK/target" CONFIRM=1
[ "$(cat "$WORK/target/app.txt")" = original ]
[ "$(cat "$WORK/target/data/item")" = 'old data' ]
[ "$(cat "$WORK/target/deploy/.env.prod")" = 'old secret' ]
