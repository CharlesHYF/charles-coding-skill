# 项目交付校验、容器与部署命令入口
# 创建日期：2026-07-29
# 修改日期：2026-11-05

.DEFAULT_GOAL := help
.PHONY: help setup verify verify-all lint lint-all check test author commit push rebase publish-release
.PHONY: docker-dev docker-dev-down docker-dev-logs docker-dev-config docker-prod docker-prod-down docker-prod-logs docker-prod-config
.PHONY: build-prod backup backup-db backup-data install-package

PROJECT_NAME ?= $(notdir $(CURDIR))
VERSION ?=
DATA_DIR ?= data
DB_BACKUP_COMMAND ?=
PROJECT_DIR ?= $(CURDIR)
COMPOSE_DEV ?= docker compose --env-file .env.development
COMPOSE_PROD ?= docker compose --env-file .env.production
export PROJECT_NAME VERSION DATA_DIR DB_BACKUP_COMMAND PROJECT_DIR CONFIRM OUTPUT_DIR PACKAGE
COMMAND_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

# ---------------------- 通用 ----------------------
help: ## 显示按分组排列的命令
	@awk 'BEGIN { FS = ":.*?## " } /^# -+ .+ -+$$/ { gsub(/^# -+ | -+$$/, ""); printf "\n%s\n", $$0 } /^[a-zA-Z_-]+:.*?## / { printf "  %-24s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
setup: ## 检查工具并安装 pre-push 钩子
	bash scripts/setup.sh
lint: ## 增量规范校验（禁用字符/文件头/注释语法/注释篇幅/注释黑话/必需文件/命名/模块边界/样式注释/import 排版/测试位置/压测/集合写法/类型注解）
	bash scripts/check.sh --changed
lint-all: ## 全量规范校验
	bash scripts/check.sh --all
test: ## 运行项目测试
	bash scripts/test.sh
check: ## 运行项目测试（兼容旧入口）
	bash scripts/test.sh
verify: ## 增量校验和测试
	bash scripts/check.sh --changed
	bash scripts/test.sh
verify-all: ## 全量校验和测试
	bash scripts/check.sh --all
	bash scripts/test.sh

# ---------------------- Git ----------------------
author: ## 设置 Git 姓名和邮箱
author commit rebase publish-release:
	@bash scripts/git-commands.sh $@ $(foreach arg,$(COMMAND_ARGS),'$(arg)')
commit: ## 暂存并提交修改
rebase: ## 将当前分支变基合入 main
publish-release: ## 触发 CI 发布指定版本
push: ## 推送本地 main 到远程 main
	git push origin main:main

# ---------------------- 容器 ----------------------
docker-dev: ## 构建并启动开发环境
	$(COMPOSE_DEV) up -d --build --remove-orphans
docker-dev-down: ## 停止开发容器并保留数据卷
	$(COMPOSE_DEV) down --remove-orphans
docker-dev-logs: ## 查看开发日志，可指定 SERVICE
	$(COMPOSE_DEV) logs -f $(SERVICE)
docker-dev-config: ## 检查开发环境配置
	$(COMPOSE_DEV) config -q
docker-prod: ## 构建并启动生产环境
	$(COMPOSE_PROD) up -d --build --remove-orphans
docker-prod-down: ## 停止生产容器并保留数据卷
	$(COMPOSE_PROD) down --remove-orphans
docker-prod-logs: ## 查看生产日志，可指定 SERVICE
	$(COMPOSE_PROD) logs -f $(SERVICE)
docker-prod-config: ## 检查生产环境配置
	$(COMPOSE_PROD) config -q

# ---------------------- 部署与备份 ----------------------
build-prod: ## 创建生产部署包，可指定输出目录和 VERSION
	@bash scripts/package.sh build $(foreach arg,$(COMMAND_ARGS),'$(arg)')
backup: ## 备份代码与配置，可指定输出目录和 VERSION
	@bash scripts/package.sh backup $(foreach arg,$(COMMAND_ARGS),'$(arg)')
backup-db: ## 用 DB_BACKUP_COMMAND 备份数据库，可指定输出目录和 VERSION
	@bash scripts/package.sh backup-db $(foreach arg,$(COMMAND_ARGS),'$(arg)')
backup-data: ## 备份 DATA_DIR，可指定输出目录和 VERSION
	@bash scripts/package.sh backup-data $(foreach arg,$(COMMAND_ARGS),'$(arg)')
install-package: ## 预览安装包；CONFIRM=1 执行同步
	@bash scripts/package.sh install $(foreach arg,$(COMMAND_ARGS),'$(arg)')

ifneq ($(filter author commit rebase publish-release build-prod backup backup-db backup-data install-package,$(firstword $(MAKECMDGOALS))),)
$(COMMAND_ARGS):
	@:
endif
