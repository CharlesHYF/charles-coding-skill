# 脚手架工程的命令入口，封装环境启动、Docker 操作、规范校验与测试
# 创建日期：2026-07-29
# 修改日期：2026-09-21

.PHONY: help dev test prod docker-up docker-up-build docker-down docker-down-v docker-clean check lint lint-all verify verify-all

# 环境变量：dev/test/prod，默认 dev，可用 ENV=xxx 覆盖
ENV ?= dev

ifeq ($(ENV),dev)
ENV_FILE := .env.development
else ifeq ($(ENV),test)
ENV_FILE := .env.test
else ifeq ($(ENV),prod)
ENV_FILE := .env.production
else
$(error 未知 ENV=$(ENV)，可选 dev/test/prod)
endif

COMPOSE := docker compose --env-file $(ENV_FILE)

help: ## 显示帮助信息
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

dev: ## 启动开发环境（锁定 .env.development，不受 ENV 变量影响）
	docker compose --env-file .env.development up -d

test: ## 启动测试环境（锁定 .env.test，不受 ENV 变量影响）
	docker compose --env-file .env.test up -d

prod: ## 启动生产环境（锁定 .env.production，不受 ENV 变量影响）
	docker compose --env-file .env.production up -d

docker-up: ## 按 ENV 启动容器（默认 dev，可 ENV=xxx 覆盖）
	$(COMPOSE) up -d

docker-up-build: ## 按 ENV 重新构建并启动容器（默认 dev，可 ENV=xxx 覆盖）
	$(COMPOSE) up -d --build

docker-down: ## 按 ENV 停止容器（默认 dev，可 ENV=xxx 覆盖）
	$(COMPOSE) down

docker-down-v: ## 按 ENV 停止容器并删除数据卷（默认 dev，可 ENV=xxx 覆盖）
	$(COMPOSE) down -v

docker-clean: ## 按 ENV 彻底清理（停容器+删卷+删本地镜像+清孤儿容器，仅本项目，不影响其它项目）
	$(COMPOSE) down -v --rmi local --remove-orphans

lint: ## 规范校验（只查本次改动；禁用字符/文件头/注释语法/注释篇幅/注释黑话/必需文件/命名/模块边界/样式注释/import 排版/测试位置/压测）
	bash scripts/check.sh --changed

lint-all: ## 规范校验（全量扫描）
	bash scripts/check.sh --all

check: ## 运行所有测试
	bash scripts/test.sh

verify: ## 交付前总闸门：增量规范校验，全绿后再跑测试
	bash scripts/check.sh --changed
	bash scripts/test.sh

verify-all: ## 全量闸门：全量规范校验，全绿后再跑测试（推主干与 CI 用）
	bash scripts/check.sh --all
	bash scripts/test.sh
