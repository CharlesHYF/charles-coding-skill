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

## 代码风格
- 使用 `gofmt` 统一格式化（注意：gofmt 用 Tab，与全局一致）
- 错误处理：自定义错误类型，结合 `errors.Is` / `errors.As` 传递上下文
- 并发：优先使用 `goroutine` + `channel`，必要时使用 `sync` 原语

## 测试
- 单元测试：标准库 `testing` + `testify/assert`
- Mock：接口抽象 + 手动 mock 或 `gomock`
- 风格：表驱动测试，覆盖率参见全局策略
