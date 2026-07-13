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
- **实体类包名统一为 `entity`**：所有数据库实体（`@Entity` / MyBatis 映射的 PO）一律放在 `entity` 包下。**禁止**自行新建 `pojo`、`model`、`domain`、`dataobject` 等同义包名（`ReqVO` / `RespVO` / `DTO` 各自按 [SKILL.md](../SKILL.md) 数据传输命名规范分包，不要混入 `entity`）
- 缩进：Tab
- 格式化工具：强制使用 Checkstyle + Spotless（Maven 插件）
- 异常处理：全局 `@RestControllerAdvice` 统一捕获，返回规范 `Result` 对象

## 微服务架构规范
> 中大型 / 微服务项目遵循以下 Maven 多模块与分层约定（源自实践项目，Spring Cloud Alibaba + Dubbo）。小型单体项目可只保留分层与统一响应部分。

### Maven 多模块划分
- `xx-dependencies`：BOM，统一管理所有依赖版本（`<packaging>pom</packaging>`，`dependencyManagement` 导入），业务模块只写坐标不写版本
- `xx-framework`：**通用能力封装**，每类能力做成独立的自研 `spring-boot-starter`（如 `starter-redis`、`starter-mq`、`starter-mybatis`、`starter-security`、`starter-web`、`starter-job`、`starter-file`、`starter-websocket` 等）+ 一个 `common` 放公共 pojo/异常/枚举/工具
- `xx-gateway`：网关；`xx-infra`：基础设施服务（文件、动态线程池等）
- **业务模块**（如 `xx-system`、`xx-platform`）再拆两个子模块：
  - `xx-xxx-api`：对外暴露的 **RPC 接口（Dubbo）** 与其 `dto` 包，供其它模块依赖
  - `xx-xxx-service`：接口实现与全部业务代码

### service 模块内分层（包结构）
- `controller/{业务域}/`：控制器，其下 `vo/` 包放该域的 `XxxReqVO` / `XxxRespVO`（见命名）
- `service/{业务域}/`：业务接口 `XxxService` + 实现 `XxxServiceImpl`
- `dal/mapper/`：MyBatis-Plus Mapper 接口；`dal/entity/`：实体（见「实体类包名统一为 entity」）；`dal/es/repository/`：ES 仓储（如有）
- `api/{业务域}/XxxApiImpl`：本模块对外 RPC 接口的实现
- `enums/`：枚举；模块内配置放 `framework/`

### 命名（与 [SKILL.md](../SKILL.md) 数据传输规范一致）
- 实体：`XxxDO` 或业务前缀实体名，继承公共基类 `BaseDO`（含 `createTime`/`updateTime`/逻辑删除等公共字段）
- 请求 `XxxReqVO`（保存 `XxxSaveReqVO`、分页 `XxxPageReqVO`）、响应 `XxxRespVO`
- RPC 传输：`XxxReqDTO` / `XxxRespDTO`，放 api 模块的 `dto` 包
- Service：接口 `XxxService`，实现 `XxxServiceImpl`

### 统一响应与异常
- **统一响应体** `Result<T>`：字段 `code` / `msg` / `data`，提供静态 `Result.success(data)` 与 `Result.error(errorCode)`；分页统一用 `PageResult<T>`
- **异常体系**：业务异常抛 `ServiceException(ErrorCode)`；`ErrorCode` 承载 code+msg；每个模块集中定义 `ErrorCodeConstants`；全局 `@RestControllerAdvice` 统一转换为 `Result`
- Controller 方法一律返回 `Result<T>` / `Result<PageResult<T>>`，用静态 `success(...)` 包装

### 惯用注解与写法
- **依赖注入**：字段注入用 `@Resource`（非 `@Autowired`）
- **Swagger/OpenAPI**：Controller 类加 `@Tag(name=...)`，每个接口方法加 `@Operation(summary=...)`
- **Controller 分节**：同一控制器内用 `// ==================== 分组名 ====================` 注释分隔不同业务分组
- **Lombok**：实体/VO 用 `@Data`；实体额外 `@Builder @NoArgsConstructor @AllArgsConstructor @EqualsAndHashCode(callSuper = true)`
- **MyBatis-Plus**：实体标 `@TableName(value = "表名", autoResultMap = true)`、主键 `@TableId`

## 开发工作流（以新增 REST 接口为例）
1. 定义 API 契约（请求 `XxxReqVO` / 响应 `XxxRespVO`；跨服务则用 `XxxDTO`）
2. 编写 MyBatis Mapper 接口及 XML / 注解 SQL
3. 实现 Service 层业务逻辑
4. 实现 Controller 层，参数校验、异常捕获交给全局处理器
5. 编写单元测试（覆盖 Mapper、Service、Controller 关键路径，参见全局覆盖率策略）
6. 自测通过后，**AI 将代码 commit 到 `agents/feature/xxx` 分支**，由 Charles 审查后合并或发起 PR
