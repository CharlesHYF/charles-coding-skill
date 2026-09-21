---
name: charles-review
description: Use when reviewing code in Charles's projects, including reviewing output produced by subagents - runs the mechanical spec checker first, then reviews business logic, so review effort goes where scripts cannot reach.
metadata:
  version: "4.0.0"
  author: Charles <w1400214654@outlook.com>
---

# 代码审查

> 审查自己或子 Agent 产出的代码时使用。原则：**机器能查的不用眼睛查**，人的注意力留给脚本查不了的部分。

## 前置阅读
- [交付红线](../charles-coding-standards/SKILL.md)
- [变更类型闸门表](../charles-coding-standards/rules/process.md)

## 步骤

### 1. 先跑校验器
```bash
make verify
```
**这是第一步，不是最后一步。** 规范类问题以脚本结论为准，不逐条肉眼找。脚本红的先让对方改完再进入人工审查，否则审查意见会被淹没在格式问题里。

### 2. 判定变更类型是否正确
对照 [闸门表](../charles-coding-standards/rules/process.md) 确认：
- 声称是重构，实际却改了对外行为，属于误报类型，要求拆分提交
- 声称是 Bug 修复，却没有复现测试，打回
- 新功能没有模块文档，打回

### 3. 审业务实现
脚本查不到的部分，按这个顺序看：

- **分层是否被击穿**：Controller 里有没有业务逻辑，Service 里有没有直接操作数据库，有没有跨层调用
- **错误路径**：异常有没有被吞掉，失败时的状态是否一致，有没有资源泄漏
- **边界条件**：空集合、null、超长输入、并发写入
- **重复代码**：两处逐字一致的代码段说明耦合未抽离
- **命名是否表达真实业务含义**：脚本只能拦截占位名，拦不住"名字看着对但含义不符"

### 4. 审测试质量
- 测试是否真的会因为 Bug 而失败，还是只覆盖了happy path
- 断言是否具体，`assertNotNull` 这类弱断言等于没测
- 有没有为了通过而放宽阈值、跳过用例

### 5. 给结论
- 每条意见附具体位置（文件路径加行号）与依据，不给"建议优化一下"这类无法执行的意见
- 区分必须改与可以改，不把个人偏好写成阻塞项
- 确认没问题就明确说通过，不用模糊表述

## 子 Agent 产出的审查
子 Agent 是隔离上下文，规范遵守率显著低于主 Agent。审查它的产出时：
1. 先跑 `make verify`，返工循环由脚本自动触发
2. 重点检查它是否读了 `AGENTS.md` 与模块文档（看实现与文档是否对得上）
3. 检查它有没有超出任务边界改了不该改的文件
