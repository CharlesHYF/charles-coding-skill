---
name: charles-new-feature
description: Use when building a new feature or module in Charles's projects, or when changing the behavior of an existing one - enforces requirement clarification, the module-doc gate before coding, and test cases before delivery.
metadata:
  version: "4.0.0"
  author: Charles <w1400214654@outlook.com>
---

# 开发新功能 / 需求变更

> 新增对外行为，或改变已有功能的对外行为时使用。这两档共用一套流程，区别在模块文档是新写还是改写。

## 前置阅读
- [变更类型闸门表](../charles-coding-standards/rules/process.md)
- [架构与代码组织](../charles-coding-standards/rules/architecture.md)
- 目标语言的 `languages/` 与 `stacks/` 分册

## 步骤

### 1. 问清需求，不许边写边猜
逐个功能确认：需求边界、入参与出参、异常场景、依赖关系、与已有功能的交互。**需求没问清不许开写。**

判断是新功能还是需求变更：
- 新增对外行为、新增模块 -> 新功能
- 已有功能的行为被改变 -> 需求变更，额外确认影响面、上下游调用方与兼容性

### 2. 写模块文档并评审
- **新功能**：写 `docs/modules/<系统模块>/<模块名>.md`，每个功能至少包含功能描述、入参要求、参数、返回
- **需求变更**：改已有文档的对应小节，被废弃的行为标注失效而不是直接删除

**文档评审通过后再进入编码。** 这一步是闸门，不是建议。

### 3. 编码
- 按三层架构落地：Controller 只做校验与转发、Service 承载业务、Repository 只做存取
- 文件内排列顺序、定义集中、方法顺序按 [architecture.md](../charles-coding-standards/rules/architecture.md)
- 命名、注释、文件头按 [naming.md](../charles-coding-standards/rules/naming.md) 与 [text.md](../charles-coding-standards/rules/text.md)
- 代码实现必须与模块文档一致；实现过程中发现文档有问题，回头改文档再继续

### 4. 写测试用例
- 用例文档放 `test_cases/<系统模块>/<类型>/x.md`
- 需求变更时同步修改已有用例，跑**全量回归**确认没有连带破坏

### 5. 交付前自检
```bash
make verify
```
全绿才算完成。未实跑不得声称通过。

## 交付闸门
- 模块文档与实现一致
- 用例文档齐备且实跑通过
- `make verify` 全绿
- 提交在 `agents/feature/*` 分支，无 AI 署名
