# 项目名称

> **强制要求**  
> 每次提交涉及功能、接口、环境配置或运行方式的变更后，**必须同步更新本 README**。  
> 这是代码审查的必检项，不更新 README 的 PR 视为不完整。

## 目录
- [项目简介](#项目简介)
- [技术栈](#技术栈)
- [快速开始](#快速开始)
- [项目结构](#项目结构)
- [常用命令](#常用命令)
- [API 文档](#api-文档)（如有）
- [部署说明](#部署说明)
- [贡献指南](#贡献指南)
- [维护者](#维护者)

## 项目简介
<!-- 用 2-3 句话描述这个项目的用途、解决什么问题 -->

## 技术栈
- 前端：Vue 3 / React (Next.js)
- 后端：Java (Spring Boot) / Go (Gin) / Python (FastAPI)
- 数据库：PostgreSQL / MySQL
- 其他：Docker Compose ...

## 快速开始
### 前置要求
- Docker & Docker Compose
- Java 17 / Go 1.22+ / Python 3.10+ / Node.js 20+（根据项目实际）

### 本地运行
```bash
# 1. 克隆项目
git clone ...

# 2. 启动依赖服务
docker-compose up -d

# 3. 安装依赖
# 前端
cd frontend && pnpm install
# 后端
cd backend && mvn install / go mod tidy / uv sync

# 4. 启动开发服务器
# ...
```

## 项目结构

<!-- 简要列出主要目录和文件，保持与最新代码同步 -->

## 常用命令

运行 `make` 或 `make help` 查看按分组排列的命令。

### 校验与 Git

```bash
make setup                                    # 检查基础工具并安装 pre-push 钩子
make verify                                   # 增量规范校验和测试
make verify-all                               # 全量规范校验和测试
make author Charles w1400214654@outlook.com   # 设置当前仓库的提交身份
make commit "提交说明"                         # 暂存并提交当前修改
make push                                     # 推送本地 main 到远程 main
make rebase main                              # 当前分支变基到 main，然后快进 main
make publish-release v1.3.0                   # 触发 CI 发布
```

发布需要已登录的 GitHub CLI 和远程 `main` 上的 `release.yml`。CI 基于远程 `main` 验证，通过后覆盖同名 `release/v1.3.0` 分支及 `v1.3.0` 标签；也可使用 `make publish-release VERSION=v1.3.0`。

### 容器

`make docker-dev` 和 `make docker-prod` 构建并启动对应环境；分别使用 `docker-dev-down` / `docker-prod-down` 停止容器，`-logs` 查看日志，`-config` 检查配置。停止命令保留数据卷，日志命令可通过 `SERVICE` 指定服务。

项目需自行提供 Compose 配置和环境文件。默认使用 `.env.development` 与 `.env.production`；可通过 `COMPOSE_DEV` 和 `COMPOSE_PROD` 调整 Compose 命令。

### 备份与部署

备份默认存入 `~/Documents/<项目名>/backup/`、`backup-db/` 或 `backup-data/`；项目名默认取仓库目录名，可用 `PROJECT_NAME` 覆盖。版本通过 `VERSION=v1.3.0` 指定，省略时要求当前提交有形如 `v1.3.0` 的标签。同一天同版本重名时保留原包，依次追加 `(2)`、`(3)`。

```bash
make backup VERSION=v1.3.0
make backup-db "~/backup" VERSION=v1.3.0 DB_BACKUP_COMMAND="pg_dump mydb"
make backup-data "~/backup" VERSION=v1.3.0 DATA_DIR=data
make build-prod VERSION=v1.3.0
make install-package "~/backup/package.zip"
make install-package "~/backup/package.zip" CONFIRM=1
```

数据库备份由项目提供 `DB_BACKUP_COMMAND`，该命令必须将备份内容输出到标准输出；`DATA_DIR` 默认为项目下的 `data`。代码备份包含配置，部署包排除环境文件和密钥；两者均排除数据目录。备份不包含符号链接。备份包可能包含密钥，应妥善保存。

安装默认只预览，确认后才同步；目标目录可用 `PROJECT_DIR` 指定，默认为当前项目目录。安装同步会删除包中已不存在的旧代码，但保留数据目录、环境文件和 `deploy/secrets/`。数据库和数据文件不随代码包恢复，配置与密钥需人工恢复。安装前应先备份。

三个备份命令和 `build-prod` 均可传输出目录；`install-package` 必须指定包路径，不会自动选择最新包。路径含空格时使用 `OUTPUT_DIR="路径"`，安装时使用 `PACKAGE="路径"`。

## API 文档

<!-- 如使用 Swagger/OpenAPI，贴访问地址；否则贴关键接口说明 -->

## 部署说明

<!-- 环境变量、构建命令、发布流程 -->

## 贡献指南

详见 [CONTRIBUTING.md](./CONTRIBUTING.md)