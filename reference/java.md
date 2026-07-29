# Charles Coding — Java
> charles-coding 的 Java 分册。**先遵循 [SKILL.md](../SKILL.md) 的「全局约定」**（缩进=Tab、中文注释、Git 分支、覆盖率策略等），本文件只列 Java 专属规范。

## 能力范围
- 后端 Web 服务、微服务架构（Android 见 [kotlin-android.md](kotlin-android.md)）

## 技术栈与工具
- JDK：1.8、17、最新 LTS 灵活切换
- 构建：Maven（主）；Gradle（Kotlin DSL，`build.gradle.kts`）为可选备选，同一项目只用一种
- **`pom.xml` 必须显式锁定 JDK 版本**：不写则 IDE（IntelliJ Project Structure）会回落到默认 JDK 5，导致编译/语法级别错乱。父 pom 里用 `<properties>` 定 `<java.version>` 并配置编译插件（多模块项目在**父 pom** 统一声明，子模块继承）：
  ```xml
  <properties>
  	<java.version>17</java.version>
  	<maven.compiler.source>${java.version}</maven.compiler.source>
  	<maven.compiler.target>${java.version}</maven.compiler.target>
  	<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>
  ```
  JDK 9+ 也可用 `<maven.compiler.release>${java.version}</maven.compiler.release>` 替代 source/target。Gradle 则用 `java { sourceCompatibility = JavaVersion.VERSION_17 }`
- 框架：Spring Boot
- ORM：**Spring Boot 项目一律用 MyBatis-Plus**（不用裸 MyBatis），善用其 `BaseMapper` / `IService` / 条件构造器 / 分页插件
- 日志：SLF4J + Logback
- 测试：JUnit 5 + Mockito（单元测试），集成测试按需扩展

## 代码风格
- 字段：`redisTemplate`（小驼峰）
- 常量：`ABC_CCC`（全大写下划线）
- 包名：全小写
- **数据库实体包名统一为 `entity`**：所有**数据库实体**（`@Entity` / MyBatis 映射的 PO）一律放在 `entity` 包下，**禁止**把数据库实体放进 `pojo`、`model`、`domain`、`dataobject` 等包。`ReqVO` / `RespVO` / `DTO` 各自按 [SKILL.md](../SKILL.md) 数据传输命名规范分包，不要混入 `entity`
  - 注意：`pojo` 不是被禁的包，它有**另一种正当用途**——见下方「通用层（common）包结构」，放 `Result` / `PageResult` / `PageParam` 等框架基础类。禁的只是「把数据库实体塞进 pojo」
- 缩进：Tab
- 格式化工具：强制使用 Checkstyle + Spotless（Maven 插件）
- 异常处理：全局 `@RestControllerAdvice` 统一捕获，返回规范 `Result` 对象
- **文件头注释用标准 Javadoc**（类上方），在标准格式基础上补「创建日期 / 修改日期」（见 [SKILL.md](../SKILL.md) 注释规范）：
  ```java
  /**
   * 举报表 DO
   *
   * @author Charles_XDXD
   * 创建日期：2026-07-15
   * 修改日期：2026-07-15
   */
  ```
  （修改日期每次实质性修改时更新为当前日期）
  说明性注释一律 `/** */`，禁止用 `//` 写类/方法/字段文档
- **判空兜底用 `Optional`**：可能为空的返回值/查询结果用 `Optional` 表达与处理（`Optional.ofNullable(...).map(...).orElse(...)` / `orElseThrow(...)`），**禁止**层层 `if (x != null)` 手写判空堆叠；对外可能返回空的方法优先声明返回 `Optional<T>`
- **对象转换用 `BeanUtil.toBean`**（Hutool）/ MapStruct 等成熟工具，在 DO <-> VO/DTO 之间转换，**禁止**自己手写一堆 `setXxx(a.getXxx())` 的封装/拷贝代码

## 微服务架构规范
> 中大型 / 微服务项目遵循以下 Maven 多模块与分层约定（源自实践项目，Spring Cloud Alibaba + Dubbo）。小型单体项目可只保留分层与统一响应部分。

### Maven 多模块划分
- `xx-dependencies`：BOM，统一管理所有依赖版本（`<packaging>pom</packaging>`，`dependencyManagement` 导入），业务模块只写坐标不写版本
- `xx-framework`：**通用能力封装**，每类能力做成独立的自研 `spring-boot-starter`（如 `starter-redis`、`starter-mq`、`starter-mybatis`、`starter-security`、`starter-web`、`starter-job`、`starter-file`、`starter-websocket` 等）+ 一个 `common` 放公共 pojo/异常/枚举/工具
- `xx-gateway`：网关；`xx-infra`：基础设施服务（文件、动态线程池等）
- **业务模块**（如 `xx-system`、`xx-platform`）再拆两个子模块：
  - `xx-xxx-api`：对外暴露的 **RPC 接口（Dubbo）** 与其 `dto` 包，供其它模块依赖
  - `xx-xxx-service`：接口实现与全部业务代码
- **嵌套子模块必须是标准 Maven 模块**：业务模块下的 `-api` / `-service` 这类「模块中的模块」，各自**必须有独立 `pom.xml`**，父模块 `<packaging>pom</packaging>` 并在 `<modules>` 中声明它们，子模块 `<parent>` 指回父模块。**禁止**出现只是普通文件夹、没被 Maven 识别为 module 的伪子模块（IDE 里不显示为模块、无法独立构建即为错误）

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
- **异常体系**：业务异常抛 `ServiceException(ErrorCode)`；`ErrorCode` 承载 code+msg；全局错误码 `GlobalErrorCodeConstants`；全局 `@RestControllerAdvice` 统一转换为 `Result`
- Controller 方法一律返回 `Result<T>` / `Result<PageResult<T>>`，用静态 `success(...)` 包装

### 通用层（common）包结构
> 这些跨模块共用的基础类**不放 `entity`**，各有专属子包（以 `framework.common` 为例，如 `com.xx.framework.common`）：
- `common/exception/`：`ErrorCode`、`GlobalErrorCodeConstants`、`ServiceException`
- `common/pojo/`：`Result`、`PageResult`、`PageParam` 等统一响应/分页基础类（这里的 `pojo` 是框架基础类，不是数据库实体）
- `common/enums/`：全局通用枚举；`common/util/`：工具类
- **常量/错误码不集中在一个包**：全局错误码放 `common/exception/GlobalErrorCodeConstants`；**每个业务模块另有自己的 `ErrorCodeConstants`**（放在该模块下，如 `xx-system-api` 的根包），承载本模块专属错误码，互不干扰

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
