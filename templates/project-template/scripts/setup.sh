#!/bin/bash
# 项目初始化脚本 -- 安装依赖、准备环境变量与本地运行所需的前置条件
# 创建日期：2026-07-29
# 修改日期：2026-08-03
set -e

echo "项目初始化开始..."

# ---------- 检查必需工具 ----------
check_tool() {
  if ! command -v "$1" &> /dev/null; then
    echo "[ERROR] 缺少依赖: $1，请先安装。"
    exit 1
  fi
}

check_tool docker

if ! docker compose version >/dev/null 2>&1; then
  echo "[ERROR] 未找到 docker compose(v2)，请安装 Docker Compose 插件。"
  exit 1
fi
echo "[OK] Docker 环境已就绪"

check_tool node
echo "[OK] Node.js 已安装"

check_tool python3
echo "[OK] Python3 已安装"

# ---------- 环境变量 ----------
if [ ! -f .env ]; then
  if [ -f .env.example ]; then
    cp .env.example .env
    echo "已从 .env.example 创建 .env，请按需修改。"
  else
    echo "[WARN] 未找到 .env.example，请手动创建 .env 文件。"
  fi
fi

# ---------- 安装依赖 ----------
if [ -d frontend ]; then
  echo "安装前端依赖..."
  if [ -f frontend/pnpm-lock.yaml ]; then
    (cd frontend && pnpm install)
  else
    (cd frontend && npm install)
  fi
fi

echo "安装 Python 依赖（uv）..."
if command -v uv &> /dev/null; then
  uv sync
else
  echo "[WARN] 未安装 uv，跳过 Python 依赖安装。"
fi

echo "安装 Go 模块..."
if [ -f go.mod ]; then
  go mod tidy
fi

echo "安装 Java 依赖（Maven）..."
if [ -f pom.xml ]; then
  mvn dependency:resolve
fi

# ---------- 启动 Docker 服务 ----------
echo "启动 Docker 容器..."
docker compose up -d

echo "[OK] 初始化完成！运行 scripts/dev.sh 启动开发环境。"

# 交付闸门钩子：推 main 跑全量 verify，推其它分支跑增量
# 不装这一步的话，规范校验只剩云端 CI 事后告警，拦不住不合规的代码进远端
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	chmod +x scripts/hooks/pre-push 2>/dev/null || true
	git config core.hooksPath scripts/hooks
	echo "[OK] 已安装 pre-push 交付闸门钩子。"
else
	echo "[WARN] 当前目录不是 git 仓库，跳过钩子安装。"
fi
