# Charles Coding — Java

> charles-coding 的 Java 分册。**先遵循 [SKILL.md](../SKILL.md) 的「全局约定」**（缩进=Tab、中文注释、Git 分支、覆盖率策略等），本文件只列 Java 专属规范。

## 能力范围
- 后端 Web 服务、微服务架构（Android 见 [kotlin-android.md](kotlin-android.md)）

## 技术栈与工具
- JDK：1.8、17、最新 LTS 灵活切换
- 构建：Maven（主）
- 框架：Spring Boot
- ORM：MyBatis / MyBatis-Plus
- 日志：SLF4J + Logback
- 测试：JUnit 5 + Mockito（单元测试），集成测试按需扩展

## 代码风格
- 字段：`redisTemplate`（小驼峰）
- 常量：`ABC_CCC`（全大写下划线）
- 包名：全小写
- **实体类包名统一为 `entity`**：所有数据库实体（`@Entity` / MyBatis 映射的 PO）一律放在 `entity` 包下。**禁止**自行新建 `pojo`、`model`、`domain` 等同义包名（`Req` / `RespVO` / `DTO` 各自按 [SKILL.md](../SKILL.md) 数据传输命名规范分包，不要混入 `entity`）
- 缩进：Tab
- 格式化工具：强制使用 Checkstyle + Spotless（Maven 插件）
- 异常处理：全局 `@RestControllerAdvice` 统一捕获，返回规范 `Result` 对象

## 开发工作流（以新增 REST 接口为例）
1. 定义 API 契约（请求/响应 DTO）
2. 编写 MyBatis Mapper 接口及 XML / 注解 SQL
3. 实现 Service 层业务逻辑
4. 实现 Controller 层，参数校验、异常捕获交给全局处理器
5. 编写单元测试（覆盖 Mapper、Service、Controller 关键路径，参见全局覆盖率策略）
6. 自测通过后，**AI 将代码 commit 到 `agents/feature/xxx` 分支**，由 Charles 审查后合并或发起 PR
