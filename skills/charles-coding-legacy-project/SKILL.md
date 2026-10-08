---
name: charles-coding-legacy-project
description: Use when introducing Charles's coding standards into an existing codebase that was not built with them - installing the checker in incremental mode so legacy violations do not block delivery while new code is held to the full standard.
metadata:
  version: "4.0.0"
  author: Charles <w1400214654@outlook.com>
---

# 老项目接入规范

> 给已有代码库接入规范时使用。核心原则：**新代码严格，存量不阻塞**。全量开检会产生几百条违规而无法交付，那等于没接入。

## 前置阅读
- [交付红线](../charles-coding-standards/SKILL.md)
- [变更类型闸门表](../charles-coding-standards/rules/process.md)

## 步骤

### 1. 先摸清现状，不要先改代码
```bash
bash tools/check.sh > /tmp/baseline.txt 2>&1 || true
```
记录违规总数与分布，作为基线。**这一步只看不改。**

### 2. 装增量模式的校验器
```bash
bash tools/install-check.sh <项目路径>
```
它会做三件事：
- 复制 `check.sh` 到 `scripts/`
- 在 `Makefile` 补 `lint` / `verify` / `verify-all` 目标，其中 `verify` 默认走 `--changed` 增量
- 装 `scripts/hooks/pre-push` 并配置 `core.hooksPath`

### 3. 确认增量范围正确
```bash
bash scripts/check.sh --changed
```
只应报本次改动文件的问题。如果它报了没动过的文件，说明 base 取错了，检查当前分支与 `main` 的关系。

增量检查按文件粒度：改到一个存量文件，整个文件的违规都会报出来。集合写法（检查十三）与 Python 类型注解（检查十四）在存量代码里命中最多，处理方式：
- 命中的存量写法单独一个提交，按 [refactor](../charles-coding-refactor/SKILL.md) 流程改写并证明行为等价，不和本次功能改动混在一起
- 确实不能动的文件加进 `.checkignore`，并在提交信息里写明原因

### 4. 补必需文件
老项目通常缺这几样，逐个补齐：
- `AGENTS.md`：按 [模板](templates/project-template/AGENTS.md) 生成，内联硬约束清单
- `.editorconfig` / `.gitattributes`：从脚手架复制，按项目实际语言调整缩进
- `docs/modules/` 与 `test_cases/` 目录骨架
- CI：项目没有 CI 配置时问用户是否需要，按 [编码前检查 CI](../charles-coding-standards/rules/process.md) 处理，答复记进 `AGENTS.md`

### 5. 给存量违规排优先级
不要一次性全改。按这个顺序分批处理，每批一个独立提交：
1. 会导致实际问题的：缺 `.gitignore` 导致密钥入库、硬编码密钥
2. 影响协作的：文件头缺失、注释语言混乱
3. 纯格式的：缩进、引号、换行 -- 交给格式化工具一次性处理，单独一个提交

### 6. 确认存量提交不被误伤
纯格式化的批量提交会产生巨大 diff。在提交信息里写明"仅格式化，无行为变更"，并在 `.git-blame-ignore-revs` 里登记该提交哈希，避免污染 `git blame`。

## 交付闸门
- `make verify`（增量）全绿
- 基线违规数已记录在 `docs/` 下，有明确的分批收敛计划
- 新增代码不产生任何新违规
