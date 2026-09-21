# Charles Coding -- Node.js
> charles-coding 的 Node.js 分册。**先遵循 [SKILL.md](../SKILL.md) 的交付红线与 `rules/` 通用规则**，语言层面见 [javascript-typescript.md](../languages/javascript-typescript.md)。

## 能力范围
- 服务端 HTTP 服务、后台任务、CLI 工具、构建与运维脚本

## 技术栈与工具
- 运行时：Node.js LTS，版本在 `package.json` 的 `engines` 字段显式声明，并与 `.nvmrc` 一致
- 包管理：pnpm，锁文件必须提交
- 模块：ESM（`"type": "module"`），不与 CommonJS 混用
- 框架：Express 或 NestJS，同一项目只用一种
- 测试：Vitest 或 `node:test`

## 目录结构
后端三层架构落到目录（层间约束见 [architecture.md](../rules/architecture.md)）：
```
src/
	routers/        路由与参数校验，不写业务逻辑
	services/       业务逻辑与事务编排，不直接操作数据库
	repositories/   数据存取，不写业务判断
	types/          跨模块共享类型
	config/         配置读取与校验
	utils/          无业务语义的纯函数
```

## 配置与密钥
- **禁止硬编码密钥、连接串、域名**，一律走环境变量
- 环境变量在启动时**集中读取并校验**，缺失必填项直接退出并打印缺了哪一项，不允许运行到一半才因为 `undefined` 崩溃
- `.env` 系列文件进 `.gitignore`，同时维护 `.env.example` 列出全部变量名与说明
- 配置读取集中在 `config/`，业务代码不直接读 `process.env`

## 错误处理
- **禁止吞异常**：`catch` 块里至少要记录日志或向上抛出，不允许空 `catch {}`
- 业务错误定义统一的错误类（含错误码与消息），不用裸 `throw new Error('xxx')` 传递业务语义
- HTTP 层统一错误中间件转换为响应体，不在各路由里重复写 `try/catch` 拼响应
- 进程级兜底：监听 `unhandledRejection` 与 `uncaughtException`，记录日志后退出，**不要捕获后继续运行**

## 进程与生命周期
- 长驻服务必须处理 `SIGTERM`：停止接收新请求、等待在途请求结束、关闭数据库连接后退出
- CLI 工具成功退出码 0，失败非 0；错误信息写 stderr，正常输出写 stdout
- 定时任务与常驻进程分开部署，不在 HTTP 服务进程里挂 cron

## 日志
- 结构化日志（JSON），字段固定：时间、级别、模块、消息、追踪标识
- **禁止 `console.log` 进生产代码**，统一走日志库；调试用的 `console` 在提交前清理
- 详细级别与脱敏要求见 [logging.md](../domains/logging.md)

## 文件头模板
```ts
/**
 * 处理订单创建与库存扣减的业务编排
 * 创建日期：2026-07-15
 * 修改日期：2026-09-14
 */
```

## 测试
- Service 层与 Repository 层必测，路由层覆盖参数校验与错误分支
- 数据库测试用独立测试库或事务回滚，禁止跑在开发库上
- 覆盖率要求见 [testing.md](../domains/testing.md)
