# Charles Coding — 日志
<!-- 日志规范分册 · 创建于 2026-07-29 -->

> charles-coding 日志规范分册。先遵循 [SKILL.md](../SKILL.md)。

## 规范
**所有服务端程序必须有日志**：用成熟的日志框架输出结构化日志，**禁止**用 `print` / `console.log` / `System.out.println` 打业务日志（同步 IO 阻塞、无级别、无法落盘与采集）

**用各语言当前主流最优的日志库**（异步、分级、可结构化）：

| 语言 | 推荐日志库 |
| ---- | ---------- |
| Java / Kotlin | SLF4J + Logback（异步 `AsyncAppender`） |
| Go | zap 或 zerolog（结构化、高性能） |
| Python | loguru，或标准 `logging` + `structlog` |
| Node / 前端服务 | pino（高性能结构化） |

**要求**：分级别（DEBUG/INFO/WARN/ERROR）、带时间戳与上下文（traceId/请求ID）、生产按级别与滚动策略落盘（按天/大小切割），敏感信息脱敏后再打日志

`print`/`console.log` 只允许在本地一次性调试时临时使用，**提交前必须清除**
