#!/bin/bash
# 启动本地开发环境 -- 拉起依赖服务并以开发配置运行应用
# 创建日期：2026-07-29
# 修改日期：2026-08-03
set -e

echo "启动开发环境..."

# 确保 Docker 服务运行
docker-compose up -d

# 并行启动前后端（按项目实际调整）
echo "启动后端..."
# 示例: Spring Boot
if [ -f pom.xml ]; then
  mvn spring-boot:run &
fi
# 示例: FastAPI
if [ -f pyproject.toml ]; then
  uv run uvicorn src.main:app --reload &
fi
# 示例: Gin
if [ -f go.mod ]; then
  go run ./cmd/server &
fi

echo "启动前端..."
cd frontend
if [ -f package.json ]; then
  npm run dev &
fi
cd ..

# 等待所有后台进程
wait