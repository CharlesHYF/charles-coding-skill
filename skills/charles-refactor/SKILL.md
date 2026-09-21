---
name: charles-refactor
description: Use when restructuring existing code in Charles's projects without changing its external behavior - enforces proving behavioral equivalence and forbids weakening tests to make the refactor pass.
metadata:
  version: "4.0.0"
  author: Charles <w1400214654@outlook.com>
---

# 重构

> 对外行为不变、只改内部结构时使用。包括整理代码顺序、统一注释、抽取公共模块、拆分过长函数。

## 前置阅读
- [变更类型闸门表](../charles-coding-standards/rules/process.md)
- [架构与代码组织](../charles-coding-standards/rules/architecture.md)

## 步骤

### 1. 先确认现有测试能兜住
重构的安全网是现有测试。开始前跑一遍全量测试，确认它们**当前是绿的**。测试本来就红的情况下重构，改完无法判断是不是自己弄坏的。

被重构部分没有测试覆盖时，**先补测试再重构**，补的测试针对现有行为，不针对期望行为。

### 2. 证明行为等价
动手前必须能说清改动前后对外行为为什么一致。证明不了就保留原实现。

高风险的等价性判断，逐条确认：
- 调整代码顺序：是否存在初始化依赖、顶层副作用、注册顺序要求
- 抽取公共模块：两处代码是否真的逐字等价，还是有细微差异被忽略
- 修改函数签名：所有调用方是否都改到
- 合并条件分支：边界值与空值路径是否覆盖一致

### 3. 重构
- **禁止修改测试断言、删除用例或放宽阈值**来让重构通过。测试红了说明行为变了，改回实现而不是改测试
- 重构与功能修改不混在同一次提交里
- 只要求整理代码或统一注释时，不得借机修改业务逻辑、接口、数据结构、命名和组件交互

### 4. 逐步验证
每完成一个可独立验证的改动就跑一次测试，不要攒一大批再跑。出问题时才能定位到是哪一步。

### 5. 记录未处理项
重构过程中发现 Bug 或架构问题，**只记录不修改**。交付时列出确有依据的问题，说明本次未处理，另行安排。

## 交付闸门
- 现有测试全绿，且断言与用例数量**没有减少**
- 模块文档不需要改动（行为不变即文档不变）
- `make verify` 全绿
- commit 说明标明"重构，无行为变更"
