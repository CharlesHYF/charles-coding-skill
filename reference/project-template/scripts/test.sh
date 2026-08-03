#!/bin/bash
# 文件作用：测试总入口 -- 按项目实际存在的技术栈依次执行后端/前端/E2E 测试。
# 创建日期：2026-07-29
# 修改日期：2026-08-03
set -e

echo "运行测试..."

# 后端测试
echo "Java 测试..."
if [ -f pom.xml ]; then
  mvn test
fi

echo "Go 测试..."
if [ -f go.mod ]; then
  go test ./... -cover
fi

echo "Python 测试..."
if [ -f pyproject.toml ]; then
  uv run pytest --cov --cov-fail-under=80
fi

# 前端测试
echo "前端单元测试..."
cd frontend
if [ -f package.json ]; then
  npm test --if-present
fi
cd ..

# E2E 测试（可选）
echo "E2E 测试..."
if command -v playwright &> /dev/null; then
  npx playwright test
elif [ -f node_modules/.bin/cypress ]; then
  npx cypress run
else
  echo "[SKIP] 未找到 E2E 工具，跳过。"
fi

echo "[OK] 所有测试执行完毕。"