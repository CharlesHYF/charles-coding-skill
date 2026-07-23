---
name: charles-coding
description: Use when writing, reviewing, refactoring, debugging, or scaffolding code in Java/Kotlin/Spring Boot, Go/Gin, Python/FastAPI, Vue 3, React/Next.js, Android, or SQL — including backend services, microservices, frontend apps, CLI tools, data processing, and AI/ML work. Applies Charles's full-stack conventions: tab indentation, Chinese comments, file-header blocks, naming, per-language formatters and toolchains, testing requirements, and the agents/feature/* git branch workflow.
version: 2.18.0
author: Charles <w1400214654@outlook.com>
---

# Charles Coding
> Charles 专用的全栈编码规范。**本文件只放「全局约定」+「速查索引」;各语言细则在 [`reference/`](reference/) 下的分册里。**

## 何时使用
- 在 Charles 的任意 **全栈 / 后端 / 前端 / 安卓 / 数据库 / 微服务 / CLI / 数据处理 / AI·ML** 项目中写代码或做代码审查时
- 需要遵循统一的 **注释、命名、格式化、测试、Git 分支与 PR** 规范时
- 开新项目需要脚手架时 —— 见 [`reference/project-template/`](reference/project-template/)

## 速查索引
> **写代码前**：先读下方「全局约定」，再点开对应语言的**分册**（领域名即链接）阅读细则。

| 领域（分册）                                | 主框架 / 运行时            | 格式化 / Lint                  | 测试                      |
| ------------------------------------------- | -------------------------- | ------------------------------ | ------------------------- |
| [Java](reference/java.md)                   | Spring Boot + Maven        | Checkstyle + Spotless          | JUnit 5 + Mockito         |
| [Kotlin / Android](reference/kotlin-android.md) | Kotlin + Gradle (KTS)  | ktlint / detekt                | JUnit + MockK + Espresso  |
| [Go](reference/go.md)                       | Gin + Go Modules           | gofmt + go vet + golangci-lint | testing + testify         |
| [Vue](reference/vue.md)                     | Vue 3 + Vite + TS          | Prettier + ESLint              | Vitest + Playwright       |
| [React](reference/react.md)                 | Next.js (App Router) + TS  | Prettier + ESLint（或 Biome）  | Vitest + RTL + Playwright |
| [Python](reference/python.md)               | FastAPI + uv               | Ruff + mypy                    | pytest（覆盖率 ≥80%）     |
| [SQL](reference/sql.md)                     | PostgreSQL / MySQL / SQLite | 关键字大写 + 2 空格 + 阿里巴巴规约 | —                         |

> **缩进**默认 **Tab**；例外：**Python / Kotlin 4 空格**、**SQL / YAML / JSON 2 空格**。**行尾**统一 **LF**。以上由脚手架里的 `.editorconfig` + `.gitattributes` 强制，不靠自觉。

## 全局约定
> 本节所有规范（大括号、代码展开/换行、魔法数字、命名、注释等）**适用所有语言，含前端**（JS / TS / Vue / React / HTML / CSS），不限于后端。

### 编辑与格式
| 项目       | 规范                                                              |
| ---------- | ----------------------------------------------------------------- |
| 缩进       | 默认 Tab；Python / Kotlin 4 空格、SQL / YAML / JSON 2 空格（见 `.editorconfig`） |
| 行尾       | 统一 LF，由 `.gitattributes` 强制（不再"跟随 OS 默认"）           |
| 编码       | UTF-8                                                             |
| 注释语言   | 中文                                                              |
| 代码格式化 | 强制使用各语言对应的格式化工具（见各分册），并由 `.editorconfig` 兜底 |
| 禁用符号   | **严禁**在代码、注释、提交信息中使用「」这类弯角引号；统一用 `""` / `''` 或直接不加引号 |

### 代码块与大括号规范
- **强制使用大括号**：`if`、`else`、`for`、`while`、`function` 等所有控制流/函数体语句，**无论内部只有一行还是多行，都必须使用大括号 `{}`**，禁止省略
- **大括号前后留空行**：代码块（`{}`）与上方相邻代码之间留一个空行，与下方相邻代码之间也留一个空行，让代码块的起止边界清晰可辨
- 示例：
  ```java
  int a = 10;

  if (a > 10) {
      // 即使只有一行也必须用大括号
      doSomething();
  } else {
      doOther();
  }

  System.out.println(a);
  ```

### 代码展开与换行规范（严禁并排）
- **对象/字典/结构体/映射字面量：每个键值独占一行**，并带行尾逗号，**严禁**多个键值并排在同一行：
  ```js
  // ✗ 禁止并排
  const p = { x: 12, y: 13, z: 14 };

  // ✔ 每项一行 + 行尾逗号
  const p = {
  	x: 12,
  	y: 13,
  	z: 14,
  };
  ```
- **HTML / JSX：每个元素独占一行**，**严禁**把多个标签挤在同一行（如 `<li>a</li><li>b</li>`）；单个标签的多个属性可保留在同一行
- **CSS：每条声明独占一行**；选择器分组时**每个选择器一行**（逗号后换行）；`{` 不另起行，跟在选择器后；**每个规则块之间空一行**。示例：
  ```css
  /* 响应式 */
  @media (max-width: 1080px) {
  	.hero,
  	.scenario-wrap {
  		grid-template-columns: 1fr;
  	}

  	.cards-3 {
  		grid-template-columns: repeat(2, 1fr);
  	}
  }
  ```
- 完整可参考的范例文件：`/Library/CodeProject/sangkee-expo/sangkee-expo.html`

### 常量与魔法数字规范
- **禁止魔法数字**：代码中**严禁**直接出现裸数字（如 `if (count > 100)`、`Thread.sleep(5000)`），所有有语义的数字必须定义为具名常量，置于文件/类顶部
- **常量命名**：全大写下划线 `MAX_RETRY_COUNT`、`DEFAULT_TIMEOUT_MS`，见名知义
- 示例：
  ```java
  // 文件顶部定义
  private static final int MAX_RETRY_COUNT = 3;

  // 使用（禁止 if (retryCount > 3)）
  if (retryCount > MAX_RETRY_COUNT) {
      // ...
  }
  ```

### Markdown 规范
- **严禁**使用 `---` / `***` / `___` 等任何形式的分割线（水平线）
- 段落正文开头**缩进一个 Tab**（两个字符宽）；**例外：`README.md` 正文开头不缩进**（顶格书写）
- **标题与其正文之间不留空行**：标题行的下一行直接紧接正文（或子标题），不插入空行

### README 规范
- **每次修改代码后**必须检查 `README.md` 是否需要同步更新（技术栈、功能列表、目录结构、启动方式、配置说明等发生变化时同步改动），保持文档与代码一致
- README 标题**居中**，使用 `<h1 align="center">` 写法：`<h1 align="center">项目名称</h1>`
- README **必须包含徽章（badge）**，置于标题下方并**居中**，至少涵盖：主要语言/框架及版本、构建/CI 状态（如有）、License、版本号；按项目补充覆盖率、依赖等。统一用 [shields.io](https://shields.io) 风格
- 徽章示例（居中，`<div align="center">` 包裹）：
  ```markdown
  <div align="center">

  ![Java](https://img.shields.io/badge/Java-17-orange)
  ![Spring Boot](https://img.shields.io/badge/Spring%20Boot-2.7-brightgreen)
  ![License](https://img.shields.io/badge/license-MIT-blue)

  </div>
  ```
- **推荐章节结构**（按项目裁剪）：`# 标题` → 徽章 → `## 介绍` → `## 软件架构`（附架构图）→ `## 技术栈` → `## 项目亮点/特点` → `## 使用说明`（启动步骤、账号、配置项）
- **徽章健壮性约束**（避免渲染成源码/裂图）：
  - 一律用 Markdown 图片语法 `![label](url)`，**禁止**手写 `<svg>`/`<img>` 内联标签（多个内联 SVG 的重复 `id` 会互相冲突，导致徽章显示成 SVG 源码）
  - URL 中的特殊字符必须转义：空格 `%20`、非 ASCII（如中文）用 URL 编码，`-` 在字段值内写 `--`
  - 徽章数量克制（建议 ≤6），信息优先于装饰
  - **同一组徽章写在同一行**（各 `![]()` 之间用空格分隔，不要每个徽章单独占一行），确保水平排列
  - **提交前必须实际验证渲染效果**：确认在目标平台（GitHub / Gitee）以图片正常显示，不能只看 URL 拼对

### 数据传输命名规范
- **前后端交互**：请求参数用 `XxxReqVO`，响应返回给前端用 `XxxRespVO`。示例：`LoginReqVO` / `LoginRespVO`
  - 细分：新增/保存 `XxxSaveReqVO`、分页查询 `XxxPageReqVO`
- **内部/跨服务传输**（RPC、服务/模块之间）：用 `XxxReqDTO` / `XxxRespDTO`（统称 `XxxDTO`）
- 三者边界：`ReqVO` = 入参（前端 → 后端）、`RespVO` = 出参（后端 → 前端展示）、`DTO` = 内部流转，不直接暴露给前端
- **适用语言**：上述 `XxxReqVO` / `XxxRespVO` / `XxxDTO` 命名是 **Java / Kotlin / TypeScript（前端 types/）** 的规范，Go 和 Python 按各自生态习惯等义表达，不照搬后缀：
  - **Go**：请求 `XxxRequest` / 响应 `XxxResponse`，内部 DTO 用 `XxxDTO`（或直接传领域对象），放在对应 `model/` 或 `dto/` 包下
  - **Python（FastAPI + Pydantic）**：用 Pydantic model，命名 `XxxCreate` / `XxxUpdate` / `XxxResponse` / `XxxFilter` 等，放在 `schemas/` 或 `models/` 下，语义与 VO/DTO 对齐即可

### 变量与函数命名规范
- **见名知义**：变量名、函数名必须能清晰表达其用途，**禁止**单字母变量（`i`/`j`/`k` 仅限循环索引）、缩写拼凑、无意义命名（`n`、`tmp`、`data`、`obj`、`item1` 等）
- **集合遍历**：循环变量要体现元素含义，用 `for (Item item : items)` 而非 `for (Item i : items)`；用 `for (User user : users)` 而非 `for (User u : users)`
- 示例：
  ```java
  // ✔ 正确
  for (Order order : orders) { process(order); }
  String customerName = order.getCustomerName();

  // ✗ 禁止
  for (Order o : orders) { process(o); }
  String n = order.getCustomerName();
  ```

### 分层架构规范
> 无论语言，所有后端项目**强制**遵循三层架构，Agent 不得把所有逻辑写在一个文件/一个函数里。

- **控制层（Controller / Handler / Router）**：只做参数校验、路由转发、调用 Service，**不写业务逻辑**
- **业务层（Service）**：承载全部业务逻辑、事务编排、跨模块调用，**不直接操作数据库**
- **数据层（Repository / DAO / Mapper / DAL）**：只做数据存取（CRUD），**不写业务判断**
- **层间调用链**：Controller → Service → Repository，**禁止跨层**（Controller 不直接调 Repository）
- 各语言对应：
  | 层 | Java / Kotlin | Go | Python（FastAPI） |
  |---|---|---|---|
  | 控制层 | `controller/` | `handler/` 或 `controller/` | `routers/` 或 `api/` |
  | 业务层 | `service/` | `service/` | `services/` |
  | 数据层 | `dal/mapper/` + `dal/entity/` | `repository/` 或 `dao/` | `repositories/` 或 `models/` |

#### 解耦原则
- **非必要不耦合**：模块之间尽量松耦合，一个模块的修改不应导致无关模块连锁改动
- 具体约束：
  - **禁止循环依赖**：A 调 B 则 B 不能直接/间接调 A
  - **禁止跨层耦合**：上层可依赖下层，下层不可反向依赖上层（数据层不能 import 业务层）
  - **禁止横向耦合过深**：两个平级业务模块（如订单模块、用户模块）之间只允许通过 Service 接口调用，禁止直接 import 对方的内部实现（Mapper、私有工具类等）
  - **重复即耦合信号**：发现两个模块有「逐字一致」的代码段，说明耦合未抽离——必须提取公共模块，而非各自保留一份

### 注释规范
- **所有开发类源代码文件**顶部必须包含注释块，说明：
  - 文件作用
  - 创建日期（格式：`YYYY-MM-DD`）
  - 修改日期（格式：`YYYY-MM-DD`，紧跟在创建日期下方；每次实质性修改时更新为当前日期）
- 文件的**详细修改历史由 git 记录**，文件头只维护上述最近一次的修改日期，不逐条罗列变更
  - **文件头只写作用，不写实现**：文件头注释仅用 1-3 句话概括本文件职责，**禁止**在文件头写入实现细节、设计推演、查证结论、环境差异分析——这些内容属于函数注释或 git commit message
- **优先使用语言标准的块/文档注释**：类、方法、字段的说明性注释优先用 `/** */`（文档注释）或 `/* */`，而**不是** `//`。`//` 只用于函数体内部的临时/单行说明。凡语言有文档注释标准（Javadoc / JSDoc / TSDoc / Go doc / docstring 等）的，一律按标准写
- **多行块注释首行换行**：`/** */` / `/* */` 等多行块注释，首行仅写 `/**`（其后立即换行），正文每行以 ` * ` 开头，末行仅写 ` */`；**禁止** `/**` 与第一行正文挤在同一行。示例：
  ```java
  /**
   * 拉阶段产物 → GET /api/tasks/{taskId}/artifact?phase=
   * phase 缺省 1（关键词，向后兼容）；phase=2 市场调研 / phase=3 Listing 聚合
   * narrative 内部结构因阶段而异，调用方按需收窄（见 PhaseArtifactVO）
   */
  ```
- **所有函数/方法**必须注释其功能，复杂逻辑需额外说明设计意图
- **注释简洁扼要**：说明「做什么、为什么」，不重复代码本身已表达的信息，不把 git commit message 的内容复制到注释里
- **禁止用注释声明跨文件重复**：注释中**禁止**出现「与 xxx.py 逐字一致」「同 xxx.java 的实现」等声明。如果两处逻辑确实相同，应抽取为公共模块（import 复用）而非用注释标记重复——注释引用另一个文件意味着存在应消除的耦合
- **Python 文件额外要求**：文件首行声明 `# -*- coding: utf-8 -*-`，置于文件作用注释之前
- **SQL 文件**：复杂查询或迁移脚本须在文件顶部注释目的及影响范围

### Git 规范
| 项目       | 规范                                      |
| ---------- | ----------------------------------------- |
| 作者       | Charles <w1400214654@outlook.com>         |
| 提交信息   | 符合社区常规（建议 Conventional Commits） |
| 署名归属   | 仅署名 Charles，**禁止**任何 AI 联合署名  |

#### .gitignore 规范
- **所有 Git 项目必须包含 `.gitignore`**，覆盖以下常见忽略项（不限于此，按项目实际补充）：
  - **IDE / 编辑器**：`.idea/`、`.vscode/`、`*.swp`、`*.swo`、`*~`
  - **AI 工具残留**：`.superpower/`、`.claude/`、`.cursor/`、`.codex/`、`.agents/`、`.opencode/`
  - **操作系统**：`.DS_Store`（macOS）、`Thumbs.db`（Windows）、`Desktop.ini`（Windows）、`*.lnk`（Windows）
  - **依赖与构建**：`node_modules/`、`vendor/`、`__pycache__/`、`*.pyc`、`target/`（Java）、`dist/`、`build/`
  - **运行时**：`.env`、`.env.local`、`*.log`、`*.pid`、`coverage/`
- 脚手架模板 `reference/project-template/.gitignore` 已包含上述常见项，新项目直接复制为起点，再按语言/框架追加

#### 禁止 AI 署名（commit/push 时必须遵守）
> **目的**：避免 GitHub 上出现 `claude` / Agent 作为提交者或 contributor（如 "CharlesHYF and claude" 的联合署名）。

- **禁止** 在提交信息中添加任何 AI 联合署名 trailer，包括但不限于：
  - `Co-Authored-By: Claude <noreply@anthropic.com>`
  - `Co-Authored-By: <任何 AI / Agent / Bot>`
  - 末尾的 `🤖 Generated with ...` 之类的 AI 生成声明
- **禁止** 把 author / committer 设为 Agent 或 AI 身份；author 与 committer 必须始终为 `Charles <w1400214654@outlook.com>`
- 提交前确认 `git config user.name` = `Charles`、`user.email` = `w1400214654@outlook.com`；必要时用 `git commit --author="Charles <w1400214654@outlook.com>"` 显式指定
- 提交信息正文只描述「做了什么、为什么」，不出现任何 AI / 工具相关的署名或水印

### Git 分支与 AI 协作权限
- **主分支**：`main`（或其他主干分支），仅由 Charles 本人合并或发起 Pull Request
- **AI 工作区**：所有 AI 生成的代码必须提交到 `agents/feature/xxx` 分支，**禁止**直接提交到主干或发起 PR
- **工作流**：
  1. AI 在 `agents/feature/xxx` 分支上开发并 commit
  2. Charles 审查代码后，手动合并到 `main` 或通过 PR 合入
  3. AI 不参与代码审查和合并操作

### Docker 规范
- **强制使用 Docker Compose**：禁止手写 `docker run` 命令，所有容器编排通过 `docker-compose.yml`（或 `compose.yml`）管理
- **服务命名在最前**：`docker-compose.yml` 中每个服务必须显式定义 `container_name`，放在该服务定义的最前面，见名知义
- **数据持久化到项目目录**：所有容器数据目录必须挂载到项目根目录下的 `volumes/<服务名>/`，如 `./volumes/mysql:/var/lib/mysql`，禁止使用 Docker 匿名卷
- **容器时区东八区**：所有容器**强制**设置环境变量 `TZ=Asia/Shanghai`，确保容器时间为北京时间
- 示例：
  ```yaml
  services:
    db:
      container_name: myproject-mysql
      image: mysql:8.0
      environment:
        - TZ=Asia/Shanghai
      volumes:
        - ./volumes/mysql:/var/lib/mysql
  ```

### 环境与配置规范
- **三套环境齐全**：配置文件**必须**区分 **开发（dev）、测试（test）、生产（prod）** 三套环境，缺一不可；各环境的连接串、域名、密钥、开关等隔离，禁止用一份配置跑所有环境
  - Java/Spring Boot：`application-dev.yml` / `application-test.yml` / `application-prod.yml` + `application.yml` 用 `spring.profiles.active` 切换
  - 前端（Vite/Next）：`.env.development` / `.env.test` / `.env.production`（详见各前端分册）
  - 其它语言按各自生态等义拆分（Go 的 config 目录分环境、Python 的 settings 分环境等）
- **生产环境必须加密代码与配置**：交付/部署到生产时，**强制**对代码与配置文件做加密/脱敏保护，禁止明文暴露
  - **配置加密**：生产配置中的敏感项（数据库密码、密钥、token 等）必须加密存储——Spring Boot 用 Jasypt（`ENC(...)`）或接入配置中心（Nacos 加密 / Vault / KMS），密钥不入库不进 git
  - **代码加密/保护**：生产制品做代码混淆或加密——Java 用 ProGuard/字节码加密（如 classfinal / xjar），前端构建产物开启混淆压缩、关闭 sourcemap，禁止把可读源码与 `.map` 发布到生产
  - **敏感文件不进版本库**：含真实密钥的 `application-prod.yml`、`.env.production`、证书私钥等一律加入 `.gitignore`，仓库内只保留 `*.example` 模板

### 调试与测试
| 项目     | 规范                                                         |
| -------- | ------------------------------------------------------------ |
| 接口测试 | Postman                                                      |
| 调试方式 | 优先查看日志，万不得已才打断点                               |
| 覆盖率   | 后端核心逻辑 ≥80%；前端关键路径与公共组件必测；脚本/原型按需 |
| 用例文档 | 测试用例在 Markdown 中**用表格记录**，不用大段文字描述        |

#### 测试用例表格格式
- 编写/交付测试用例文档时，**必须用 Markdown 表格**呈现，禁止只用几句话笼统描述
- 表头固定包含以下列（按此顺序）：**测试编号、优先级、测试用例、前置条件、输入内容、预计结果、实际结果、是否通过、备注**
  - 核心必填：测试编号、测试用例、输入内容、预计结果、实际结果、是否通过
  - `是否通过` 填 Pass / Fail，是明确的达标判定；`优先级` 用 P0-P3 或 高/中/低；无前置条件填 `-`
- 示例：

  | 测试编号 | 优先级 | 测试用例 | 前置条件     | 输入内容            | 预计结果             | 实际结果 | 是否通过 | 备注 |
  | -------- | ------ | -------- | ------------ | ------------------- | -------------------- | -------- | -------- | ---- |
  | TC-001   | P0     | 正常登录 | 账号已注册   | 正确的账号密码      | 登录成功，返回 token | 待填写   | 待填写   | -    |
  | TC-002   | P1     | 密码错误 | 账号已注册   | 正确账号 + 错误密码 | 提示密码错误         | 待填写   | 待填写   | -    |

#### 测试用例强制要求
- **Agent 写完代码后必须提供测试用例**，放在项目根目录的 `test_cases/` 文件夹下，工整组织
- 按模块/功能分文件命名，如 `test_cases/login_test_cases.md`（文档式）或各语言测试文件（`test_login.py`、`login_test.go` 等）
- **必须实际运行并确保全部通过**后再交付，禁止交付未验证的测试
- **覆盖三套环境**：测试用例/测试内容必须覆盖 **开发、测试、生产** 三套环境的验证（如各环境配置能正确加载、连接对应资源），不能只在开发环境验证

### AI 协作模式
- 先给出方案确认，再生成具体代码（参照 superpowers skills 理念）
- AI 的所有代码产出均提交至 `agents/` 命名空间下的分支，由 Charles 最终决策和集成
- **严禁最小 MVP / 敷衍方案**：不许给「先跑起来再说」的残缺 demo、占位空实现、`TODO` 糊弄的代码。要给**完整、可用、有理有据**的方案，把边界情况、错误处理、配置都做全
- **务必说人话**：解释与文档用直白清楚的中文，讲清「是什么、为什么、怎么做」；**禁止**模棱两可、故弄玄虚、堆砌高深术语而不落地。有取舍就把利弊讲明，给明确推荐

#### 编码前置流程（先问清、再动手）
- **编码前必须从底层把每个功能问清楚**：进入写代码环节之前，逐个功能向 Charles 确认需求边界、入参出参、异常场景、依赖关系，需求没问清不许开写
- **必须先写好模块文档**，放在 `docs/modules/<模块名>.md`（如 `docs/modules/orders.md`），文档本身遵循本 Skill 的 Markdown 规范
- 每个功能在文档里至少包含：**功能描述、入参要求、参数、返回**等小节（详见 [reference/module-doc-template.md](reference/module-doc-template.md)）
- 文档评审通过后再进入编码；代码实现须与文档一致，文档随功能变更同步更新

#### AGENT.md（项目级 AI 指令）
- **每个项目根目录必须包含 `AGENT.md`**，作为 AI 工具进入项目时首先读取的指令文件
- 内容至少包含：引用 `charles-coding` Skill、声明分支策略、列出常用命令
- 模板：
  ```markdown
  # AGENT.md

  ## 编码规范
  请严格遵循 charles-coding Skill（https://github.com/CharlesHYF/charles-coding-skill）的全部约定。

  ## 分支策略
  所有代码提交到 `agents/feature/<描述>` 分支，禁止直接推 `main` 或发起 PR。
  Charles 审查后手动合并。

  ## 常用命令
  # 启动：...
  # 构建：...
  # 测试：...
  ```

## 新项目脚手架
开新项目时，直接复制 [`reference/project-template/`](reference/project-template/) 作为起点，内含：AGENT.md / README / Makefile / `scripts/`（setup·dev·migrate·test）/ `.editorconfig` / `.gitattributes` / `.gitignore` / `.github/pull_request_template.md`。
