.PHONY: help start stop test lint

help: ## 显示帮助信息
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

start: ## 启动开发环境（Docker Compose）
	docker-compose up -d

stop: ## 停止开发环境
	docker-compose down

test: ## 运行所有测试
	@echo "请根据项目语言单独执行测试命令"

lint: ## 代码检查（各语言汇总）
	@echo "请使用各自语言的 linter"