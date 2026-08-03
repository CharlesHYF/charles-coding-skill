# AGENTS.md
> 项目级 AI 指令文件。各主流 AI 编码工具(Claude Code / Codex / Cursor 等)进入项目时优先读取本文件。
>
> **本文件内联了硬约束原文，不是指针。** 无论主 agent 还是子 agent，动手写代码前必须读完本文件；不得以"稍后去读 skill"代替。完整细则见 charles-coding Skill 各分册，但下方清单即为交付红线。

## 0. 交付红线(必须满足，否则不算完成)
- 交付前必须跑 `make verify`(先规范校验 `scripts/check.sh`，再跑测试 `scripts/test.sh`)，**全绿才算完成**。
- 测试必须实跑并全部通过，禁止"看起来对"就交付。
- 代码提交到 `agents/feature/<描述>` 分支，禁止直接推 `main` 或发起 PR，禁止任何 AI 联合署名。

## 1. 命名硬约束(高频踩坑，逐条对照)
- **Java / Kotlin / TS**：请求(入参) `XxxReqVO`、响应(出参) `XxxRespVO`、内部/跨服务 `XxxDTO`。细分：新增/保存 `XxxSaveReqVO`、分页 `XxxPageReqVO`。**禁止**裸 `XxxVO`、`XxxDTO` 直接当请求/响应暴露给前端。
- **Go**：请求 `XxxRequest`、响应 `XxxResponse`，内部 `XxxDTO`。
- **Python(FastAPI + Pydantic)**：`XxxCreate` / `XxxUpdate` / `XxxResponse` / `XxxFilter`。
- **变量/函数见名知义**：禁止单字母(`i`/`j` 仅限循环索引)、`tmp`/`data`/`obj`/`item1` 等无意义名；遍历用 `for (Order order : orders)` 而非 `for (Order o : orders)`。

## 2. 文件头注释块(每个源码文件必须有)
每个源码文件顶部必须含以下三行(按语言注释语法适配)，`scripts/check.sh` 会校验前两项：

```
文件作用：<一到两句话说明本文件职责，句号结尾>
创建日期：YYYY-MM-DD
修改日期：YYYY-MM-DD
```

- 文件头**只写作用，不写实现**：禁止写实现细节、设计推演、查证结论。
- Python 文件首行加 `# -*- coding: utf-8 -*-`，置于文件作用之前。

## 3. 禁用字符(纯文本规则，`scripts/check.sh` 会校验)
- **禁止**弯角引号(中文弯引号)，统一用半角 `"` / `'` 或不加引号。
- **禁止**中文长破折号(EM DASH)，统一用半角双连字符 `--`。
- **禁止** Emoji 出现在代码、注释、文档、提交信息中；需图标用 SVG 或 icon 字体。

## 4. 结构与格式硬约束
- **分层架构**：后端强制 Controller → Service → Repository，禁止跨层(Controller 不直接调 Repository)，禁止把全部逻辑塞进一个文件/函数。
- **强制大括号**：所有 `if`/`else`/`for`/`while`/函数体，即使只有一行也要 `{}`；代码块前后留空行。
- **禁止魔法数字**：裸数字提为文件/类顶部具名常量(`MAX_RETRY_COUNT` 等)。
- **键值/元素独占一行**：对象字面量每个键值一行带尾逗号；HTML/JSX 每个元素一行；禁止并排。
- **缩进**：默认 Tab；Python / Kotlin 4 空格、SQL / YAML / JSON 2 空格(见 `.editorconfig`)。行尾统一 LF。
- **注释语言**：一律中文。

## 5. 编码前置流程(先问清、再动手)
- **模块文档闸门**：新模块/新功能**必写** `docs/modules/<模块>.md`(含功能描述、入参、参数、返回)，评审通过后再编码。小改/bugfix/重构豁免，但需在 commit/PR 说明。
- 需求边界、入参出参、异常场景没问清，不许开写。

## 6. 常用命令
```bash
make verify   # 交付前总闸门：规范校验 + 测试(全绿才算完成)
make lint     # 仅规范校验(禁用字符/文件头/必需文件/命名)
make check    # 仅跑测试
make dev      # 启动开发环境
```

---
> 硬约束以本文件为准；未覆盖的细则(各语言格式化工具、测试框架、SQL/日志/DevOps 规范等)见 charles-coding Skill 的 `reference/` 分册。
