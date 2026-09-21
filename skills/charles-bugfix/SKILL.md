---
name: charles-bugfix
description: Use when fixing a bug, test failure, or unexpected behavior in Charles's projects - enforces root-cause analysis and writing a failing reproduction test before touching implementation code.
metadata:
  version: "4.0.0"
  author: Charles <w1400214654@outlook.com>
---

# 修复 Bug

> 实现与既定行为不符时使用。这一档最容易被跳过测试，所以下面的顺序是硬要求，不是建议。

## 前置阅读
- [变更类型闸门表](../charles-coding-standards/rules/process.md)
- [测试规范](../charles-coding-standards/domains/testing.md)

## 步骤

### 1. 定位根因
能说清"为什么会出现这个现象"再动手。**看到报错就改表象是无效修复**：

- 复现问题，确认触发条件
- 沿调用链向上追，找到第一个产生错误状态的位置
- 区分四类原因：输入数据问题、逻辑错误、依赖行为变化、环境配置差异
- 根因定位不了就先加日志或断点，不要靠猜测改代码

### 2. 先写复现测试
**这一步在改实现之前。**

- 写一个能稳定复现该 Bug 的测试
- 运行它，**确认它失败**，且失败原因正是这个 Bug
- 测试不失败说明它没复现问题，重写

### 3. 改实现
改到第 2 步的测试通过为止。只改与根因直接相关的代码，不顺手重构、不顺手改格式。

### 4. 跑回归
跑该模块全量测试，确认没有引入新问题。

### 5. 保留测试
复现测试放 `test_cases/<系统模块>/regression/`，**不允许修完就删**。它的作用是防止同一个 Bug 再次出现。

### 6. 检查文档
如果修复过程中发现模块文档描述的行为本身就是错的，回头改文档，并在 commit 说明里写明。

## 例外
只改一两行的显性笔误（拼写错误、常量值写反、条件符号写反）可以跳过第 2 步，但必须在 commit 说明里注明原因。**不确定算不算显性笔误时，按正常流程走。**

## 交付闸门
- 复现测试已提交并通过
- 模块全量测试通过
- `make verify` 全绿
- commit 说明写清根因与修复方式，不只写"修复 bug"
