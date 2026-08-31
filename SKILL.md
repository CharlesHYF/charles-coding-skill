---
name: charles-coding
description: Use when writing, reviewing, refactoring, debugging, or scaffolding code in Java/Kotlin/Spring Boot, Go/Gin, Python/FastAPI, Vue 3, React/Next.js, Android, or SQL -- including backend services, microservices, frontend apps, CLI tools, data processing, and AI/ML work. Applies Charles's full-stack conventions: tab indentation, Chinese comments, file-header blocks, naming, per-language formatters and toolchains, testing requirements, and the agents/feature/* git branch workflow.
version: 3.4.0
author: Charles <w1400214654@outlook.com>
---

# Charles Coding
> Charles 专用的全栈编码规范。**本文件只放"全局约定"+"速查索引";各语言细则在 [`reference/`](reference/) 下的分册里。**

## 何时使用
- 在 Charles 的任意 **全栈 / 后端 / 前端 / 安卓 / 数据库 / 微服务 / CLI / 数据处理 / AI·ML** 项目中写代码或做代码审查时
- 需要遵循统一的 **注释、命名、格式化、测试、Git 分支与 PR** 规范时
- 开新项目需要脚手架时  --  见 [`reference/project-template/`](reference/project-template/)

## 速查索引
> **写代码前**：先读下方"全局约定"，再点开对应语言的**分册**（领域名即链接）阅读细则。

| 领域（分册）                                | 主框架 / 运行时            | 格式化 / Lint                  | 测试                      |
| ------------------------------------------- | -------------------------- | ------------------------------ | ------------------------- |
| [Java](reference/java.md)                   | Spring Boot + Maven        | Checkstyle + Spotless          | JUnit 5 + Mockito         |
| [Kotlin / Android](reference/kotlin-android.md) | Kotlin + Gradle (KTS)  | ktlint / detekt                | JUnit + MockK + Espresso  |
| [Go](reference/go.md)                       | Gin + Go Modules           | gofmt + go vet + golangci-lint | testing + testify         |
| [Vue](reference/vue.md)                     | Vue 3 + Vite + TS          | Prettier + ESLint              | Vitest + Playwright       |
| [React](reference/react.md)                 | Next.js (App Router) + TS  | Prettier + ESLint（或 Biome）  | Vitest + RTL + Playwright |
| [Python](reference/python.md)               | FastAPI + uv               | Ruff + mypy                    | pytest（覆盖率 ≥80%）     |
| [SQL](reference/sql.md)                     | PostgreSQL / MySQL / SQLite | 关键字大写 + 2 空格 + 阿里巴巴规约 | --                         |

> **缩进**默认 **Tab**；例外：**Python / Kotlin 4 空格**、**SQL / YAML / JSON 2 空格**。**行尾**统一 **LF**。以上由脚手架里的 `.editorconfig` + `.gitattributes` 强制，不靠自觉。

## 专项规范
- [文档与Markdown](reference/readme-md.md)
- [DevOps与部署安全](reference/devops.md)
- [测试与压测](reference/testing.md)
- [日志](reference/logging.md)
- [AI/ML](reference/ai-ml.md)

## 全局约定
> 本节所有规范（大括号、代码展开/换行、魔法数字、命名、注释等）**适用所有语言，含前端**（JS / TS / Vue / React / HTML / CSS），不限于后端。

### 编辑与格式
#### 工具强制类（由 Prettier/gofmt/Ruff + editorconfig 自动保证，不靠自觉）
| 项目       | 规范                                                              |
| ---------- | ----------------------------------------------------------------- |
| 缩进       | 默认 Tab；Python / Kotlin 4 空格、SQL / YAML / JSON 2 空格（见 `.editorconfig`） |
| 行尾       | 统一 LF，由 `.gitattributes` 强制（不再"跟随 OS 默认"）           |
| 编码       | UTF-8                                                             |
| import 排序 | 由各语言格式化工具（Prettier/gofmt/Ruff 等）自动整理             |
| 代码格式化 | 强制使用各语言对应的格式化工具（见各分册）自动执行                |

#### 禁用符号（scripts/check.sh 拦截，非纯手动）
> 以下由脚手架 `scripts/check.sh` 扫描拦截（`make lint` 与 CI 均会 fail），不是纯手动自查。规则句一律用**码点**指代被禁字符，故本文件自身不含被禁字符。

| 类别   | 规范                                                                                     |
| ------ | ---------------------------------------------------------------------------------------- |
| 引号   | 严禁 Unicode 弯引号（U+2018/2019/201C/201D）、CJK 角引号（U+300C-300F）、全角引号（U+FF02/FF07）；统一用 ASCII 直引号 `"` / `'` 或不加引号。书名号《》(U+300A/300B) 是正常中文标点，不禁。 |
| 破折号 | 严禁 Unicode 破折号/横线，含 em dash、en dash 等（U+2010-2015、U+2212、U+FF0D、U+2E3A/2E3B）；统一用半角双连字符 `--`（两个 U+002D）。目录树制表符（U+2500~257F）不禁。 |
| Emoji  | 严禁在代码、注释、文档、提交信息中出现 Emoji；确需图标用 SVG 或 icon 字体。 |

#### 手动约定类（工具不保证，Agent 须手动遵守并自查）
| 项目             | 规范                                                              | lint 提示 |
| ---------------- | ----------------------------------------------------------------- | --------- |
| 注释语言         | 中文                                                              | 无法配置，纯手动 |
| 大括号前后空行   | 见下方"代码块与大括号规范"                                       | 无法配置，纯手动 |
| 键值独占一行     | 见下方"代码展开与换行规范"                                       | ESLint `object-curly-newline` |
| 魔法数字         | 见下方"常量与魔法数字规范"                                       | `no-magic-numbers` |
| 命名见名知义     | 见下方"变量与函数命名规范"                                       | 无法配置，纯手动 |

### 代码块与大括号规范
- **强制使用大括号**：`if`、`else`、`for`、`while`、`function` 等所有控制流/函数体语句，**无论内部只有一行还是多行，都必须使用大括号 `{}`**，禁止省略
- **大括号前后留空行**：代码块（`{}`）与上方相邻代码之间留一个空行，与下方相邻代码之间也留一个空行，让代码块的起止边界清晰可辨
- 示例：
  ```java
  if (a > 10) {
      doSomething();
  } else {
      doOther();
  }
  ```

### 代码展开与换行规范（严禁并排）
- **对象/字典/结构体/映射字面量：每个键值独占一行**，并带行尾逗号，**严禁**多个键值并排在同一行：
  ```js
  const p = {
  	x: 12,
  	y: 13,
  };
  ```
- **HTML / JSX：每个元素独占一行**，**严禁**把多个标签挤在同一行（如 `<li>a</li><li>b</li>`）；单个标签的多个属性可保留在同一行
- **CSS：每条声明独占一行**；选择器分组时**每个选择器一行**（逗号后换行）；`{` 不另起行，跟在选择器后；**每个规则块之间空一行**。示例：
  ```css
  .hero,
  .scenario-wrap {
  	grid-template-columns: 1fr;
  }
  ```
- 完整可参考的范例文件：[`example.html`](example.html)；测试用例范例见 [`reference/examples/test_cases/`](reference/examples/test_cases/)；模块文档范例见 [`reference/examples/docs/modules/`](reference/examples/docs/modules/)

### 常量与魔法数字规范
- **禁止魔法数字**：代码中**严禁**直接出现裸数字（如 `if (count > 100)`、`Thread.sleep(5000)`），所有有语义的数字必须定义为具名常量，置于文件/类顶部
- **常量命名**：全大写下划线 `MAX_RETRY_COUNT`、`DEFAULT_TIMEOUT_MS`，见名知义
- 示例：
  ```java
  private static final int MAX_RETRY_COUNT = 3;
  if (retryCount > MAX_RETRY_COUNT) {
      return;
  }
  ```

### 数据传输命名规范
- **原则：每种语言遵循自己生态的主流命名，不强制统一后缀**。三类边界一致：请求 = 入参（前端 → 后端）、响应 = 出参（后端 → 前端展示）、DTO = 内部/跨服务流转（不直接暴露给前端）；后缀按各语言生态取用。
- **Java / Kotlin / TypeScript（前端 types/）**：请求 `XxxReqVO`、响应 `XxxRespVO`、内部 `XxxDTO`（`XxxReqDTO` / `XxxRespDTO`）。细分：新增/保存 `XxxSaveReqVO`、分页查询 `XxxPageReqVO`。示例：`LoginReqVO` / `LoginRespVO`
- **Go**：请求 `XxxRequest`、响应 `XxxResponse`，内部 `XxxDTO` 或直接传领域对象，放 `model/` 或 `dto/` 包
- **Python（FastAPI + Pydantic）**：用 Pydantic model，命名 `XxxCreate` / `XxxUpdate` / `XxxResponse` / `XxxFilter`，放 `schemas/` 或 `models/`

### 变量与函数命名规范
- **见名知义**：变量名、函数名必须能清晰表达其用途，**禁止**单字母变量（`i`/`j`/`k` 仅限循环索引）、缩写拼凑、无意义命名（`n`、`tmp`、`data`、`obj`、`item1` 等）
- **集合遍历**：循环变量要体现元素含义，用 `for (Item item : items)` 而非 `for (Item i : items)`；用 `for (User user : users)` 而非 `for (User u : users)`
- 示例：
  ```java
  // 正确：
  for (Order order : orders) { process(order); }
  String customerName = order.getCustomerName();

  // 禁止：
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
  - **重复即耦合信号**：发现两个模块有"逐字一致"的代码段，说明耦合未抽离 -- 必须提取公共模块，而非各自保留一份

### 注释规范
- **所有开发类源代码文件**必须包含注释块，三行，顺序固定：
  - **第一行：作用描述**。**一到两句话**说明本文件职责。**禁止加"文件作用："之类的前缀标签**，直接写描述；**句尾不加句号**
  - **第二行：创建日期**，格式 `创建日期：YYYY-MM-DD`
  - **第三行：修改日期**，格式 `修改日期：YYYY-MM-DD`，每次实质性修改更新为当前日期
  - **冒号必须是中文全角 `：`**，禁止半角 `:`（`scripts/check.sh` 会拦截）
  - **注释块位置**：有 `package`/`import` 的语言（Java/Kotlin）放在**类型声明上方**（Javadoc/KDoc），类上有注解则放在**注解之上**，而非文件物理第一行；其余语言放文件顶部；Python 的 `# -*- coding: utf-8 -*-` 仍置于最顶
- 标准化模板（各语言按各自注释语法适配，示例见各分册"文件头模板"章节）：
  ```
  应用入口 -- 启动 Spring Boot 并加载全部配置
  创建日期：2026-07-15
  修改日期：2026-08-01
  ```
  ```
  错误写法：文件作用：应用入口 -- 启动 Spring Boot 并加载全部配置。   <- 多了前缀标签、多了句号
  错误写法：创建日期: 2026-07-15                                      <- 半角冒号
  ```
- 文件的**详细修改历史由 git 记录**，文件头只维护上述最近一次的修改日期，不逐条罗列变更
  - **文件头只写作用，不写实现**：文件头注释仅用 1-2 句话概括本文件职责，**禁止**在文件头写入实现细节、设计推演、查证结论、环境差异分析 -- 这些内容属于函数注释或 git commit message
#### 注释语法对照表（先查表，再动手写）
> **多行注释一律用块/文档注释语法，禁止用连续多行 `//` 或 `#` 拼出多行注释。** 单行注释才用 `//` / `#`。

| 语言                                    | 多行 / 文档注释（文件头、类、方法、字段） | 单行注释 |
| --------------------------------------- | ----------------------------------------- | -------- |
| Java / Kotlin                           | `/** ... */`（Javadoc / KDoc）            | `//`     |
| JS / TS / JSX / TSX / CSS / SCSS / k6    | `/** ... */`（JSDoc / TSDoc）；CSS 用 `/* */` | `//`（CSS 无单行注释，仍用 `/* */`） |
| Go                                       | 见下方 **Go 例外**                        | `//`     |
| Python                                   | `"""` docstring（三段式）                 | `#`      |
| Vue SFC / HTML                           | `<!-- ... -->`                            | `<!-- ... -->` |
| SQL                                      | `/* ... */`（文件头亦可整块用 `--`，见 [sql.md](reference/sql.md)） | `--`     |
| Shell / YAML / Dockerfile / .properties  | `#`（这些语言无块注释语法，属唯一例外）   | `#`      |

- **块注释三段式**：`/** */` / `/* */` 首行仅写 `/**`（其后立即换行），正文每行以 ` * ` 开头，末行仅写 ` */`；**禁止** `/**` 与第一行正文挤在同一行。示例：
  ```java
  /**
   * 拉阶段产物 → GET /api/tasks/{taskId}/artifact?phase=
   * phase 缺省 1，向后兼容
   */
  ```
- **Python docstring 同样三段式**：`"""` 独占首行、**正文一律从第二行开始**、`"""` 独占末行（单行内容同理）；docstring 只作模块/类/函数体内的第一个语句。统一用双引号 `"""`，**禁止** `'''`（PEP 257 标准，Ruff D300 会报错）
  ```python
  # 错误：正文跟 """ 挤在同一行
  def resolve(...):
      """把 material_refs 分类为远程链接、已复制本地素材和不可用引用三类。

      uploads_dir 是 ...
      """

  # 正确：""" 独占首行，正文第二行起
  def resolve(...):
      """
      把 material_refs 分类为远程链接、已复制本地素材、不可用引用三类
      """
  ```
- **单行说明禁止用字符串字面量**：一句话的说明性注释一律用 `//` 或 `#`，**禁止**写成 `"""xxx"""` / `'''xxx'''`。Python 里那是一条 no-op 表达式语句而非注释，既不绑定对象、也不被 `help()` / IDE 识别
- **说明性注释置于被说明对象上方**：变量/常量/字段的说明写在其上一行（Python 用 `#`），**禁止**写在下方或用悬空 `"""..."""` 充当变量文档
- **`//` / `#` 的合法用途仅两类**：① 函数体内部的单行说明；② Shell / YAML / Dockerfile 等无块注释语法的语言。除此之外的类、方法、字段、文件头说明，一律用上表的块/文档注释
- **Go 例外**：Go 的官方文档注释标准就是 `//`（`go doc` / pkg.go.dev 只识别这种形式，且要求以标识符名开头），因此 Go 的**声明级注释一律用 `//`**，即使多行也用连续 `//`，**不要**改成 `/* */`。仅**文件头注释块**用 `/* */`（见 [go.md](reference/go.md)）
- **所有函数/方法**必须注释其功能，复杂逻辑需额外说明设计意图
- **注释篇幅硬上限：正文默认 1-2 行，任何注释块正文不得超过 3 行**（`scripts/check.sh` 会拦截，`@param` / `@return` 等标签行不计入）。注释是给读代码的人一句话点明"做什么、为什么"，**不是设计文档**
  - **禁止**在注释里写：背景推演、方案权衡、为什么不选另一种做法、运行时环境分析、故障复盘、待办计划。这些属于 `docs/modules/<系统模块>/<模块>.md` 或 git commit message
  - 判据：如果一段注释删掉后，读代码的人**仍能看懂这个函数做什么**，那它就该删或压缩
  - 错误示例（正文 5 行，讲了进程模型、失败原因、为何不自动重试 -- 全属于模块文档的内容）：
    ```java
    /**
     * 把滞留在"处理中"的学习内容标记为失败
     *
     * 异步同步任务活在 JVM 进程里,进程一停任务就没了,而内容状态还留在"处理中":
     * 管理端看不出问题、课程的自动发布判定也会一直等下去。这里给出明确原因,
     * 由管理员重新保存课程触发重试 -- 不自动重试是因为妙记要以"当时的操作人"身份下载,
     * 而操作人身份没有随内容落库,重启后无从还原。
     */
    ```
  - 正确写法（1 行说清做什么，"为什么不自动重试"留给模块文档）：
    ```java
    /**
     * 把超过 STALE_MINUTES 仍滞留"处理中"的内容标记为失败，等管理员重新保存课程触发重试
     */
    ```
- **注释简洁扼要**：说明"做什么、为什么"，不重复代码本身已表达的信息，不把 git commit message 的内容复制到注释里
- **禁止用注释声明跨文件重复**：注释中**禁止**出现"与 xxx.py 逐字一致""同 xxx.java 的实现"等声明。如果两处逻辑确实相同，应抽取为公共模块（import 复用）而非用注释标记重复 -- 注释引用另一个文件意味着存在应消除的耦合
- **Python 文件额外要求**：文件首行声明 `# -*- coding: utf-8 -*-`，置于文件头注释块之前
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
  - 末尾的 `Generated with ...` 之类的 AI 生成声明
- **禁止** 把 author / committer 设为 Agent 或 AI 身份；author 与 committer 必须始终为 `Charles <w1400214654@outlook.com>`
- 提交前确认 `git config user.name` = `Charles`、`user.email` = `w1400214654@outlook.com`；必要时用 `git commit --author="Charles <w1400214654@outlook.com>"` 显式指定
- 提交信息正文只描述"做了什么、为什么"，不出现任何 AI / 工具相关的署名或水印

### Git 分支与 AI 协作权限
- **主分支**：`main`（或其他主干分支），仅由 Charles 本人合并或发起 Pull Request
- **AI 工作区**：所有 AI 生成的代码必须提交到 `agents/feature/xxx` 分支，**禁止**直接提交到主干或发起 PR
- **工作流**：
  1. AI 在 `agents/feature/xxx` 分支上开发并 commit
  2. Charles 审查代码后，手动合并到 `main` 或通过 PR 合入
  3. AI 不参与代码审查和合并操作

### 交付整洁规范
- **交付时严禁残留无用文件**：临时脚本、调试文件、废弃代码、空目录、`xxx-copy`/`xxx备份`、注释掉的大段代码等一律清理，交付物只保留真正需要的文件
- **过程产物禁止 commit**：开发过程中产生的 `spec`、`plan`、设计草稿、调研笔记、Agent 中间产物等**禁止提交到仓库**，一律写入 `.gitignore`（如 `*.spec.md`、`plan/`、`.agent/`、`scratch/` 等按项目约定），只提交最终代码与正式文档（`docs/`、`README`、`test_cases/`）

### AI 协作模式
- **一律用简体中文回答 Charles**：所有对话回复、解释、方案说明统一使用简体中文（代码内注释同样中文），禁止用英文或繁体作答
- 先给出方案确认，再生成具体代码（参照 superpowers skills 理念）
- AI 的所有代码产出均提交至 `agents/` 命名空间下的分支，由 Charles 最终决策和集成
- **严禁最小 MVP / 敷衍方案**：不许给"先跑起来再说"的残缺 demo、占位空实现、`TODO` 糊弄的代码。要给**完整、可用、有理有据**的方案，把边界情况、错误处理、配置都做全
- **务必说人话**：解释与文档用直白清楚的中文，讲清"是什么、为什么、怎么做"；**禁止**模棱两可、故弄玄虚、堆砌高深术语而不落地。有取舍就把利弊讲明，给明确推荐
- **证据驱动，先查证再作答**：凡涉及事实或技术判断的回答，动手前先把相关资料查实 -- 该读的源码、文档、配置、依赖版本、命令输出，按问题分量查到够深为止，禁止凭记忆、假设或"应该是"作答。给结论必须附依据：文件路径:行号、实跑的命令输出、官方文档、可复现结果，不能只甩结论。查不到或不确定，就明说不确定并点出缺口，绝不编造依据或伪造精确。宁可多查一步，不可拍脑袋（简短交互如"继续/看看/你决定"不在此列）

#### 编码前置流程（先问清、再动手）
- **编码前必须从底层把每个功能问清楚**：进入写代码环节之前，逐个功能向 Charles 确认需求边界、入参出参、异常场景、依赖关系，需求没问清不许开写
- **模块文档闸门**：**新模块/新功能必写** `docs/modules/<系统模块>/<模块名>.md`（两级组织,如 `docs/modules/backend/orders.md`），文档本身遵循 [reference/readme-md.md](reference/readme-md.md) 的 Markdown 规范；每个功能至少包含**功能描述、入参要求、参数、返回**等小节（详见 [reference/module-doc-template.md](reference/module-doc-template.md)）；**文档评审通过后再进入编码**，代码实现须与文档一致，文档随功能变更同步更新
- **豁免**：小改/bugfix/重构可不写模块文档，但需在 commit/PR 说明改动内容

#### AGENTS.md（项目级 AI 指令）
- **每个项目根目录必须包含 `AGENTS.md`**（复数，跨工具事实标准，Claude Code / Codex / Cursor 等均优先读取），作为 AI 工具进入项目时首先读取的指令文件
- **AGENTS.md 必须自足**：把命名、文件头、禁用字符、分层、模块文档闸门等**硬约束原文内联进去**，而非只写一句"请遵循 charles-coding Skill"。原因见下方"子 Agent 编排契约" -- 子 agent 是隔离上下文，只认它直接读到的文件，指针式引用会在转述中丢失
- 内容至少包含：交付红线（`make verify` 全绿）、内联硬约束清单、`agents/feature/*` 分支策略（禁止直接推 `main` 或发起 PR）、常用命令（启动/构建/测试）
- 完整模板见 [reference/project-template/AGENTS.md](reference/project-template/AGENTS.md)

#### 子 Agent 编排契约（subagent-driven development 专用）
> **背景**：用 subagent-driven development 派活时，每个子 agent 是**全新、隔离的上下文** -- 它读不到主 agent 的对话历史、读不到 SessionStart hook 注入、也不会主动去加载本 Skill。主 agent"知道"规范，不等于子 agent"收到"规范；中间隔着一次有损转述。规范遵守是全局约束，而 subagent 把活拆给隔离上下文，两者天然冲突，必须靠下述契约弥合。

- **派发前置**：orchestrator 向任一子 agent 派发实现类 Task 前，**必须**在 Task brief 里做到以下三件，缺一不可：
  1. **内联硬约束**：把该 Task 涉及语言的硬清单（命名 / 文件头模板 / 禁用字符 / 分层）**原文写进 brief**，不许只写"遵循 charles-coding"。可直接摘抄目标项目 `AGENTS.md` 的对应小节
  2. **强制读取指令**：brief 里明确写"开工前先 `cat AGENTS.md` 全文，并读 `docs/modules/<本模块>.md`"
  3. **声明交付闸门**：brief 里写死"交付前必须 `make verify` 全绿，否则本 Task 不算完成"
- **依赖机器兜底，不依赖转述**：确定性规则（禁用字符 / 文件头 / 命名 / 必需文件）由 `scripts/check.sh` 校验，子 agent 写歪了 `make verify` 会 fail，返工循环自动触发 -- 不靠主 agent 肉眼审。脚手架的 `make verify` = `scripts/check.sh`（规范）+ `scripts/test.sh`（测试）
- **review 阶段核对**：主 agent 收到子 agent 产物做 review 时，第一步先跑 `make verify` 看是否全绿，再看业务实现；规范类 finding 以脚本结论为准，不逐条肉眼找

## 新项目脚手架
开新项目时，直接复制 [`reference/project-template/`](reference/project-template/) 作为起点，内含：AGENTS.md（已内联硬约束清单）/ README / Makefile / `scripts/`（setup·dev·migrate·test·**check**）/ `.editorconfig` / `.gitattributes` / `.gitignore` / `.github/pull_request_template.md`。

- **规范校验器 `scripts/check.sh`**：把确定性规则（禁用字符 / 文件头 / 必需文件 / 命名）变成会 fail 的检查，由 `make verify` 在交付前强制执行，不依赖 Agent 自觉。
- **交付总闸门 `make verify`** = `scripts/check.sh`（规范）+ `scripts/test.sh`（测试），**全绿才算完成**。
