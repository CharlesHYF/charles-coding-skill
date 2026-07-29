# Charles Coding — Go
> charles-coding 的 Go 分册。**先遵循 [SKILL.md](../SKILL.md) 的「全局约定」。**

## 能力范围
- API 服务、微服务、中间件、CLI 工具

## 技术栈与工具
- 版本：最新稳定版 Go
- 依赖管理：Go Modules (`go mod`)
- Web 框架：Gin
- ORM：GORM
- 项目结构：官方推荐的布局（`cmd/`, `internal/`, `pkg/` 等）
- 代码格式化：`gofmt` + `go vet`（强制）
- 额外检查：推荐 `golangci-lint` 开启常用 linter

## 项目布局
- 遵循官方推荐布局，按职责拆分，禁止把业务代码堆进 `main.go`：
  ```
  myservice/
  ├── cmd/
  │   └── myservice/
  │       └── main.go          # 入口，只做装配（读配置、注入依赖、启动服务）
  ├── internal/                # 项目私有代码，禁止被外部模块 import
  │   ├── handler/              # HTTP/Gin 路由与入参出参处理
  │   ├── service/               # 业务逻辑
  │   ├── repository/            # 数据访问（DB/缓存）
  │   └── model/                 # XxxRequest / XxxResponse、领域模型
  ├── pkg/                       # 可被外部模块复用的公共库
  └── go.mod
  ```
- **请求/响应结构体统一放 `internal/model/`**：`XxxRequest` / `XxxResponse`，按业务域分文件（如 `user_model.go`），禁止散落在 handler 里现场定义

## 代码风格
- 使用 `gofmt` 统一格式化（注意：gofmt 用 Tab，与全局一致）
- **错误处理**：一律用 `fmt.Errorf("读取用户信息失败: %w", err)` 包装错误以保留调用链，禁止用 `%v`（会丢失底层错误类型，无法用 `errors.Is`/`errors.As` 判断）；上层用 `errors.Is(err, ErrTargetErr)` 判断哨兵错误、`errors.As(err, &customErr)` 提取自定义错误类型做进一步处理
- **并发**：优先使用 `goroutine` + `channel`，必要时使用 `sync` 原语；启动的 goroutine 必须能被外部取消（传入 `context.Context` 并在内部 `select` 监听 `ctx.Done()`），禁止起「野生」永不退出的 goroutine
- **context 传递**：所有跨层调用（handler -> service -> repository）的第一个参数一律是 `ctx context.Context`，用于传递超时、取消信号与请求级元数据（如 traceId）；禁止把 `context.Background()` 传到业务函数内部临时创建，应从最外层 handler 一路透传
- **defer / panic 约定**：
  - `defer` 用于资源释放（`file.Close()`、`db.Close()`、解锁），紧跟在资源获取语句之后，避免中间插入逻辑导致遗漏
  - **禁止**用 `panic` 做正常的错误处理流程；只在程序无法继续（如初始化失败）时使用
  - 每个 goroutine 内部若可能 panic，必须 `defer recover()` 兜底并记录日志，避免一个 goroutine panic 拖垮整个进程

## 文件头模板
```go
// Package service 用户业务逻辑
//
// 创建日期：2026-07-29
// 作者：Charles
package service
```

## 测试
- 单元测试：标准库 `testing` + `testify/assert`
- Mock：接口抽象 + 手动 mock 或 `gomock`
- 风格：表驱动测试，覆盖率参见全局策略
