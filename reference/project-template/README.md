# 项目名称

> ⚠️ **强制要求**  
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

<!-- 从 Makefile 或 package.json 中摘录关键命令 -->

## API 文档

<!-- 如使用 Swagger/OpenAPI，贴访问地址；否则贴关键接口说明 -->

## 部署说明

<!-- 环境变量、构建命令、发布流程 -->

## 贡献指南

详见 [CONTRIBUTING.md](./CONTRIBUTING.md)