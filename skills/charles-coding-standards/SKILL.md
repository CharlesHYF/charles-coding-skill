---
name: charles-coding-standards
description: Use when writing, reviewing, refactoring, debugging, organizing, or scaffolding code in Java, Kotlin, Python, Go, TypeScript, JavaScript, HTML, CSS, SQL, Node.js, Vue 3, React/Next.js, Android, or web frontends. Applies Charles's full-stack conventions, change-type delivery gates, Chinese comment and communication rules, testing requirements, and the agents/feature/* git branch workflow.
metadata:
  version: "4.0.0"
  author: Charles <w1400214654@outlook.com>
---

# Charles Coding

> Charles 的全栈编码规范。本文件只放**场景路由、交付红线和模块索引**；细则全部在 `rules/` `languages/` `stacks/` `domains/` 下，按需打开。

## 何时使用
- 在 Charles 的任意后端 / 前端 / 安卓 / 数据库 / 微服务 / CLI / 数据处理 / AI·ML 项目中写代码或做代码审查
- 需要遵循统一的注释、命名、格式化、测试、Git 分支与交付规范
- 开新项目需要脚手架，或给老项目接入规范

## 场景路由
> 先判定场景，进入对应工作流；工作流会告诉你该读哪几个规范模块。

| 场景 | 工作流 |
| --- | --- |
| 新项目初始化 | [new-project](../charles-coding-new-project/SKILL.md) |
| 老项目接入规范 | [legacy-project](../charles-coding-legacy-project/SKILL.md) |
| 开发新功能 / 需求变更 | [new-feature](../charles-coding-new-feature/SKILL.md) |
| 修复 Bug | [bugfix](../charles-coding-bugfix/SKILL.md) |
| 重构 | [refactor](../charles-coding-refactor/SKILL.md) |
| 代码审查 | [review](../charles-coding-review/SKILL.md) |

## 交付红线
> 这十三条必须记住，其余查模块。违反其中确定性规则的，`scripts/check.sh` 会直接 fail。

1. **注释用中文**，所有源码文件带文件头三行：作用描述、`创建日期：YYYY-MM-DD`、`修改日期：YYYY-MM-DD`，冒号是全角；描述**只写核心职责，禁止用 `--` 追加功能罗列**
2. **缩进默认 Tab**；Python / Kotlin 4 空格，SQL / YAML / JSON 2 空格；行尾统一 LF
3. **禁用 Unicode 弯引号、破折号、Emoji**，统一用 ASCII 直引号与半角双连字符 `--`
4. **禁止魔法数字**，有语义的数字一律定义为具名常量
5. **命名见名知义**，禁止占位名（`tmp` / `obj` / `data1`）、拼音、隐喻黑话
6. **后端强制三层架构**：Controller -> Service -> Repository，禁止跨层调用
7. **注释块正文不超过 3 行**，一条注释一行写完，不把一句话折断换行
8. **AI 代码只提交到 `agents/feature/*`**，禁止任何 AI 联合署名，禁止直接推主干或发起 PR；**一个任务对应一个 commit**
9. **交付前 `make verify` 全绿**（规范校验 + 测试），未实跑不得声称通过；测试代码集中放 `tests/`，新功能必须带压测脚本
10. **动手前先判定变更类型**，按 [流程规范](rules/process.md) 的闸门表执行对应要求
11. **样式里不写任何注释**（`.css` / `.scss` 与 Vue `<style>` 块，含文件头）；**import 顺序**为值 import 在前、`import type` 在后
12. **元素多行书写**：属性各占一行、文本单独占一行、同级元素之间空一行；只有组件自闭合，原生 HTML 标签成对出现
13. **集合处理一律显式循环**：禁止推导式、Stream、集合回调链与嵌套三元，JSX 渲染列表时单独一次 `.map` 除外；Python 函数的参数与返回类型都要写注解。细则见 [common](rules/common.md) 的"集合处理写法"

## 规范模块

### 通用规则（rules/）-- 所有语言适用
| 模块 | 内容 |
| --- | --- |
| [common](rules/common.md) | 缩进、行尾、编码、禁用符号、大括号、展开换行、常量与魔法数字、集合处理写法 |
| [naming](rules/naming.md) | 变量、函数、布尔、集合、数据传输对象命名 |
| [text](rules/text.md) | 注释语法、文件头模板、篇幅上限、折行、措辞与黑话词表 |
| [architecture](rules/architecture.md) | 分层架构、解耦原则、文件内排列顺序、已有代码修改边界 |
| [git](rules/git.md) | 提交信息、署名、分支权限、.gitignore、交付整洁 |
| [process](rules/process.md) | 变更类型闸门表、模块文档、AGENTS.md、子 Agent 契约 |
| [collaboration](rules/collaboration.md) | 工作节奏、确认边界、中文表达方式 |

### 语言（languages/）
| 分册 | 主栈 | 格式化 / Lint | 测试 |
| --- | --- | --- | --- |
| [Java](languages/java.md) | Spring Boot + Maven | Checkstyle + Spotless | JUnit 5 + Mockito |
| [Kotlin](languages/kotlin.md) | Kotlin + Gradle (KTS) | ktlint + detekt | JUnit + MockK |
| [Python](languages/python.md) | FastAPI + uv | Ruff + mypy | pytest（覆盖率 >=80%） |
| [Go](languages/go.md) | Gin + Go Modules | gofmt + go vet + golangci-lint | testing + testify |
| [JavaScript / TypeScript](languages/javascript-typescript.md) | ES2022 + TS 5 | Prettier + ESLint | Vitest |
| [HTML / CSS](languages/html-css.md) | 语义化 HTML + 原生 CSS / SCSS | Prettier + Stylelint | -- |
| [SQL](languages/sql.md) | PostgreSQL / MySQL / SQLite | 关键字大写 + 2 空格 | -- |

### 技术栈（stacks/）
| 分册 | 内容 |
| --- | --- |
| [Vue](stacks/vue.md) | Vue 3 + Vite + TS |
| [React](stacks/react.md) | Next.js App Router + TS |
| [Node.js](stacks/nodejs.md) | 服务端 JS 运行时、包管理、脚本、环境变量 |
| [Web](stacks/web.md) | 浏览器端构建、兼容性、性能、可访问性 |
| [Android](stacks/android.md) | Jetpack Compose + MVVM + Hilt |

### 领域（domains/）
| 分册 | 内容 |
| --- | --- |
| [testing](domains/testing.md) | 测试用例组织、强制要求、压测 |
| [logging](domains/logging.md) | 日志级别、格式、脱敏 |
| [devops](domains/devops.md) | Docker、环境配置、部署安全基线 |
| [ai-ml](domains/ai-ml.md) | 模型、数据集、指标回归 |
| [docs-markdown](domains/docs-markdown.md) | README、徽章、Markdown 规范 |

## 新项目脚手架
开新项目直接复制 [`templates/project-template/`](templates/project-template/)，内含 AGENTS.md（已内联硬约束）、README、Makefile、`scripts/`、`.editorconfig`、`.gitattributes`、`.gitignore`、PR 模板与 CI。

- **规范校验器** [`tools/check.sh`](tools/check.sh)：把确定性规则变成会 fail 的检查，由 `make verify` 强制执行
- **工具从 skill 目录调用，不要复制进项目**：skill 目录内有 `tools` 与 `templates` 软链，直接 `bash ~/.claude/skills/charles-coding-standards/tools/install-check.sh <项目路径>` 即可。复制过去会让 `check.sh` 变成散落各处的拷贝，skill 更新后不同步，同一条规则在不同项目里表现不一样。唯一的例外是 `install-check.sh` 往项目里装的那份 `scripts/check.sh`，它是交付闸门的一部分，必须随项目走
- **交付总闸门** `make verify` = `scripts/check.sh`（规范）+ `scripts/test.sh`（测试），全绿才算完成
- 老项目接入用 [`tools/install-check.sh`](tools/install-check.sh)，装完默认走增量检查，存量代码不阻塞
