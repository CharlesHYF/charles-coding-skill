#!/bin/bash
set -e

echo "🧪 运行测试..."

# 后端测试
echo "🔍 Java 测试..."
if [ -f pom.xml ]; then
  mvn test
fi

echo "🔍 Go 测试..."
if [ -f go.mod ]; then
  go test ./... -cover
fi

echo "🔍 Python 测试..."
if [ -f pyproject.toml ]; then
  uv run pytest --cov --cov-fail-under=80
fi

# 前端测试
echo "🔍 前端单元测试..."
cd frontend
if [ -f package.json ]; then
  npm test --if-present
fi
cd ..

# E2E 测试（可选）
echo "🔍 E2E 测试..."
if command -v playwright &> /dev/null; then
  npx playwright test
elif [ -f node_modules/.bin/cypress ]; then
  npx cypress run
else
  echo "⏭️  未找到 E2E 工具，跳过。"
fi

echo "✅ 所有测试执行完毕。"