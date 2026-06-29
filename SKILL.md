---
name: charles-coding
description: Use when writing, reviewing, refactoring, debugging, or scaffolding code in Java/Kotlin/Spring Boot, Go/Gin, Python/FastAPI, Vue 3, React/Next.js, Android, or SQL — including backend services, microservices, frontend apps, CLI tools, data processing, and AI/ML work. Applies Charles's full-stack conventions: tab indentation, Chinese comments, file-header blocks, naming, per-language formatters and toolchains, testing requirements, and the agents/feature/* git branch workflow.
version: 2.2.1
author: Charles <w1400214654@outlook.com>
---

# Charles Coding

> Charles 专用的全栈编码规范。**本文件只放「全局约定」+「速查索引」;各语言细则在 [`reference/`](reference/) 下的分册里。**

## 何时使用

- 在 Charles 的任意 **全栈 / 后端 / 前端 / 安卓 / 数据库 / 微服务 / CLI / 数据处理 / AI·ML** 项目中写代码或做代码审查时
- 需要遵循统一的 **注释、命名、格式化、测试、Git 分支与 PR** 规范时
- 开新项目需要脚手架时 —— 见 [`reference/project-template/`](reference/project-template/)

## 速查索引

> **写代码前**：先读下方「全局约定」，再点开对应语言的**分册**（领域名即链接）阅读细则。

| 领域（分册）                                | 主框架 / 运行时            | 格式化 / Lint                  | 测试                      |
| ------------------------------------------- | -------------------------- | ------------------------------ | ------------------------- |
| [Java](reference/java.md)                   | Spring Boot + Maven        | Checkstyle + Spotless          | JUnit 5 + Mockito         |
| [Kotlin / Android](reference/kotlin-android.md) | Kotlin + Gradle (KTS)  | ktlint / detekt                | JUnit + MockK + Espresso  |
| [Go](reference/go.md)                       | Gin + Go Modules           | gofmt + go vet + golangci-lint | testing + testify         |
| [Vue](reference/vue.md)                     | Vue 3 + Vite + TS          | Prettier + ESLint              | Vitest + Playwright       |
| [React](reference/react.md)                 | Next.js (App Router) + TS  | Prettier + ESLint（或 Biome）  | Vitest + RTL + Playwright |
| [Python](reference/python.md)               | FastAPI + uv               | Ruff + mypy                    | pytest（覆盖率 ≥80%）     |
| [SQL](reference/sql.md)                     | PostgreSQL / MySQL / SQLite | 关键字大写 + 2 空格           | —                         |

> **缩进**默认 **Tab**；例外：**Python / Kotlin 4 空格**、**SQL / YAML / JSON 2 空格**。**行尾**统一 **LF**。以上由脚手架里的 `.editorconfig` + `.gitattributes` 强制，不靠自觉。

## 全局约定

### 编辑与格式
| 项目       | 规范                                                              |
| ---------- | ----------------------------------------------------------------- |
| 缩进       | 默认 Tab；Python / Kotlin 4 空格、SQL / YAML / JSON 2 空格（见 `.editorconfig`） |
| 行尾       | 统一 LF，由 `.gitattributes` 强制（不再"跟随 OS 默认"）           |
| 编码       | UTF-8                                                             |
| 注释语言   | 中文                                                              |
| 代码格式化 | 强制使用各语言对应的格式化工具（见各分册），并由 `.editorconfig` 兜底 |
| 禁用符号   | **严禁**在代码、注释、提交信息中使用「」这类弯角引号；统一用 `""` / `''` 或直接不加引号 |

### Markdown 规范
- **严禁**使用 `---` / `***` / `___` 等任何形式的分割线（水平线）
- 段落正文开头**缩进一个 Tab**（两个字符宽）

### 注释规范
- **所有开发类源代码文件**顶部必须包含注释块，说明：
  - 文件作用
  - 创建日期（格式：`YYYY-MM-DD`）
- 文件的**修改历史由 git 记录**，不在文件头手工维护（避免日期过时）
- **所有函数/方法**必须注释其功能，复杂逻辑需额外说明设计意图
- **Python 文件额外要求**：文件首行声明 `# -*- coding: utf-8 -*-`，置于文件作用注释之前
- **SQL 文件**：复杂查询或迁移脚本须在文件顶部注释目的及影响范围

### Git 规范
| 项目       | 规范                                      |
| ---------- | ----------------------------------------- |
| 作者       | Charles <w1400214654@outlook.com>         |
| 提交信息   | 符合社区常规（建议 Conventional Commits） |
| 署名归属   | 仅署名 Charles，**禁止**任何 AI 联合署名  |

#### 禁止 AI 署名（commit/push 时必须遵守）
> **目的**：避免 GitHub 上出现 `claude` / Agent 作为提交者或 contributor（如 "CharlesHYF and claude" 的联合署名）。

- **禁止** 在提交信息中添加任何 AI 联合署名 trailer，包括但不限于：
  - `Co-Authored-By: Claude <noreply@anthropic.com>`
  - `Co-Authored-By: <任何 AI / Agent / Bot>`
  - 末尾的 `🤖 Generated with ...` 之类的 AI 生成声明
- **禁止** 把 author / committer 设为 Agent 或 AI 身份；author 与 committer 必须始终为 `Charles <w1400214654@outlook.com>`
- 提交前确认 `git config user.name` = `Charles`、`user.email` = `w1400214654@outlook.com`；必要时用 `git commit --author="Charles <w1400214654@outlook.com>"` 显式指定
- 提交信息正文只描述「做了什么、为什么」，不出现任何 AI / 工具相关的署名或水印

### Git 分支与 AI 协作权限
- **主分支**：`main`（或其他主干分支），仅由 Charles 本人合并或发起 Pull Request
- **AI 工作区**：所有 AI 生成的代码必须提交到 `agents/feature/xxx` 分支，**禁止**直接提交到主干或发起 PR
- **工作流**：
  1. AI 在 `agents/feature/xxx` 分支上开发并 commit
  2. Charles 审查代码后，手动合并到 `main` 或通过 PR 合入
  3. AI 不参与代码审查和合并操作

### 调试与测试
| 项目     | 规范                                                         |
| -------- | ------------------------------------------------------------ |
| 接口测试 | Postman                                                      |
| 调试方式 | 优先查看日志，万不得已才打断点                               |
| 覆盖率   | 后端核心逻辑 ≥80%；前端关键路径与公共组件必测；脚本/原型按需 |

### AI 协作模式
- 先给出方案确认，再生成具体代码（参照 superpowers skills 理念）
- AI 的所有代码产出均提交至 `agents/` 命名空间下的分支，由 Charles 最终决策和集成

## 新项目脚手架

开新项目时，直接复制 [`reference/project-template/`](reference/project-template/) 作为起点，内含：README / Makefile / `scripts/`（setup·dev·migrate·test）/ `.editorconfig` / `.gitattributes` / `.gitignore` / `.github/pull_request_template.md`。
