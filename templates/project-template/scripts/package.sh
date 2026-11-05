#!/usr/bin/env bash
# 创建备份和部署包并预览或安装代码
# 创建日期：2026-11-05
# 修改日期：2026-11-05

set -euo pipefail
umask 077
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ACTION="${1:-}"
shift || true
[ "$#" -le 1 ] || { echo '最多接受一个路径参数' >&2; exit 1; }
ARGUMENT="${1:-}"
NAME="${PROJECT_NAME:-$(basename "$ROOT")}"
VERSION_VALUE="${VERSION:-}"
DATA_PATH="${DATA_DIR:-data}"
TARGET="${PROJECT_DIR:-$ROOT}"

expand_path() {
	case "$1" in
		\~/*) printf '%s/%s\n' "$HOME" "${1#\~/}" ;;
		*) printf '%s\n' "$1" ;;
	esac
}

if [[ ! "$NAME" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
	echo '项目名称无效，请设置 PROJECT_NAME' >&2
	exit 1
fi

if [ "$ACTION" = install ]; then
	PACKAGE="$(expand_path "${ARGUMENT:-${PACKAGE:-}}")"
	TARGET="$(expand_path "$TARGET")"
	if [ -z "$PACKAGE" ]; then
		echo "请指定 zip 包路径。默认备份目录：$HOME/Documents/$NAME/backup" >&2
		exit 1
	fi
	[ -f "$PACKAGE" ] && [ -d "$TARGET" ] || { echo '安装包或目标目录不存在' >&2; exit 1; }
	STAGING="$(mktemp -d)"
	trap 'rm -rf "$STAGING"' EXIT
	python3 - "$PACKAGE" "$NAME" <<'PY'
import stat
import sys
import zipfile

package, name = sys.argv[1:]
with zipfile.ZipFile(package) as archive:
    for item in archive.infolist():
        parts = item.filename.replace("\\", "/").split("/")
        mode = item.external_attr >> 16
        if parts[0] != name or ".." in parts or stat.S_ISLNK(mode):
            raise SystemExit("压缩包包含不安全路径或软链接")
PY
	unzip -q "$PACKAGE" -d "$STAGING"
	[ -f "$STAGING/$NAME/Makefile" ] || { echo '安装包缺少项目 Makefile' >&2; exit 1; }
	TARGET="$(cd "$TARGET" && pwd -P)"
	case "$DATA_PATH" in
		/*) case "$DATA_PATH" in "$TARGET"/*) DATA_PATH="${DATA_PATH#"$TARGET"/}" ;; "$TARGET") echo '数据目录不能等于部署目录' >&2; exit 1 ;; *) DATA_PATH='' ;; esac ;;
		*..*) echo 'DATA_DIR 不能包含 ..' >&2; exit 1 ;;
	esac
	RSYNC_ARGS=(-a -c --delete --exclude=/.git/ --exclude='/data/' --exclude='/datas/' --exclude='/deploy/secrets/' --exclude='/.env*' --exclude='/deploy/.env*')
	if [ -n "$DATA_PATH" ] && [[ "$DATA_PATH" != /* && "$DATA_PATH" != *..* ]]; then
		RSYNC_ARGS+=(--exclude="/$DATA_PATH/")
	fi
	if [ "${CONFIRM:-}" != 1 ]; then
		rsync "${RSYNC_ARGS[@]}" --dry-run --itemize-changes "$STAGING/$NAME/" "$TARGET/"
		echo '以上为预览；确认后使用 CONFIRM=1，安装前请先备份。'
	else
		rsync "${RSYNC_ARGS[@]}" "$STAGING/$NAME/" "$TARGET/"
		echo "安装完成：$TARGET"
	fi
	exit 0
fi

if [ -z "$VERSION_VALUE" ]; then
	VERSION_VALUE="$(git -C "$ROOT" describe --tags --exact-match 2>/dev/null || true)"
fi
[[ "$VERSION_VALUE" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo '请设置 VERSION=v1.2.3 或在当前提交打版本标签' >&2; exit 1; }
case "$ACTION" in
	build) CATEGORY=prod ;;
	backup | backup-db | backup-data) CATEGORY="$ACTION" ;;
	*) echo '未知打包操作' >&2; exit 1 ;;
esac
OUTPUT_DIR="$(expand_path "${ARGUMENT:-${OUTPUT_DIR:-$HOME/Documents/$NAME/$CATEGORY}}")"
if [ "$ACTION" != backup-db ]; then
	echo "注意：归档不包含符号链接。"
fi
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"
STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT
mkdir -p "$STAGING/$NAME"
case "$ACTION" in
	backup | build)
		RSYNC_ARGS=(-a --no-links --exclude=/.git/ --exclude=/node_modules/ --exclude=/.venv/ --exclude=/data/ --exclude=/datas/)
		if [ -n "$DATA_PATH" ] && [[ "$DATA_PATH" != /* && "$DATA_PATH" != *..* ]]; then
			RSYNC_ARGS+=(--exclude="/$DATA_PATH/")
		fi
		if [ "$ACTION" = build ]; then
			RSYNC_ARGS+=(--exclude='/.env*' --exclude='/deploy/.env*' --exclude='/deploy/secrets/')
		fi
		rsync "${RSYNC_ARGS[@]}" "$ROOT/" "$STAGING/$NAME/"
		;;
	backup-data)
		DATA_PATH="$(expand_path "$DATA_PATH")"
		[[ "$DATA_PATH" = /* ]] || DATA_PATH="$ROOT/$DATA_PATH"
		[ -d "$DATA_PATH" ] || { echo "数据目录不存在：$DATA_PATH" >&2; exit 1; }
		mkdir -p "$STAGING/$NAME/data"
		rsync -a --no-links "$DATA_PATH/" "$STAGING/$NAME/data/"
		;;
	backup-db)
		[ -n "${DB_BACKUP_COMMAND:-}" ] || { echo '请设置 DB_BACKUP_COMMAND，备份数据须输出到标准输出' >&2; exit 1; }
		bash -o pipefail -c "$DB_BACKUP_COMMAND" > "$STAGING/$NAME/database.dump"
		[ -s "$STAGING/$NAME/database.dump" ] || { echo '数据库备份为空' >&2; exit 1; }
		;;
esac
DATE_VALUE="$(date +%Y%m%d)"
BASE="$NAME-$CATEGORY-$DATE_VALUE-$VERSION_VALUE"
INDEX=1
while :; do
	SUFFIX=''
	[ "$INDEX" -eq 1 ] || SUFFIX="($INDEX)"
	OUTPUT="$OUTPUT_DIR/$BASE$SUFFIX.zip"
	if (set -o noclobber; : > "$OUTPUT") 2>/dev/null; then
		break
	fi
	INDEX=$((INDEX + 1))
done
if ! (cd "$STAGING" && zip -qr "$STAGING/archive.zip" "$NAME") || ! cat "$STAGING/archive.zip" > "$OUTPUT"; then
	rm -f "$OUTPUT"
	exit 1
fi
echo "已生成：$OUTPUT"
