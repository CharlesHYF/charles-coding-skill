---
name: charles-new-project
description: Use when starting a brand-new project in Charles's environment and it needs scaffolding - copying the project template, installing the spec checker, writing the first module doc, and verifying the delivery gate works before any feature code is written.
metadata:
  version: "4.0.0"
  author: Charles <w1400214654@outlook.com>
---

# 新项目初始化

> 从零开新项目时使用。目标是在写第一行业务代码之前，把规范闸门装好并验证它真的会 fail。

## 前置阅读
- [交付红线](../charles-coding-standards/SKILL.md)
- 目标语言对应的 `languages/` 与 `stacks/` 分册

## 步骤

### 1. 复制脚手架
把 [`templates/project-template/`](templates/project-template/) 整体复制为项目起点，包含 `AGENTS.md`、`README.md`、`Makefile`、`scripts/`、`.editorconfig`、`.gitattributes`、`.gitignore`、PR 模板与 CI 配置。

### 2. 装规范校验器
把 [`tools/check.sh`](tools/check.sh) 复制到项目的 `scripts/check.sh`，确认 `make lint` 能跑通。

### 3. 装 pre-push 钩子
```bash
bash scripts/setup.sh
```
`setup.sh` 会执行 `git config core.hooksPath scripts/hooks`，把交付闸门装到本地。**这一步不能跳过**：推 `main` 时的全量 `make verify` 靠它拦截。

### 4. 按语言补技术栈配置
- 语言与框架选型写进 `README.md`
- 按对应分册补 `pom.xml` / `go.mod` / `pyproject.toml` / `package.json` 与格式化配置
- `.editorconfig` 按语言确认缩进（默认 Tab，Python 与 Kotlin 4 空格）

### 5. 验证闸门确实会 fail
**故意写一个违规文件**（例如文件头缺"创建日期："），跑 `make lint` 确认它报错，再删掉。闸门装了但不生效等于没装。

### 6. 写第一个模块文档
按 [模块文档模板](templates/module-doc.md) 写 `docs/modules/<系统模块>/<模块>.md`，评审通过后才进入编码。

### 7. 补 AGENTS.md
脚手架里的 `AGENTS.md` 已内联硬约束清单，按项目实际补充常用命令（启动、构建、测试）与技术栈说明。**不要改成只写一句"遵循 charles-coding"**，原因见 [子 Agent 编排契约](../charles-coding-standards/rules/process.md)。

## 交付闸门
- `make verify` 全绿
- `docs/modules/` 下至少一个两级模块文档
- `test_cases/` 下至少一个两级用例文档
- `git config core.hooksPath` 已指向 `scripts/hooks`
