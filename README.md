<div align="center">

<img src="assets/banner-light.png" alt="charles-coding" width="880">

![Version](https://img.shields.io/badge/version-4.0.0-blue) ![Languages](https://img.shields.io/badge/languages-Java%20%7C%20Kotlin%20%7C%20Python%20%7C%20Go%20%7C%20TypeScript%20%7C%20Vue%20%7C%20React-informational) ![AI Tools](https://img.shields.io/badge/AI%20tools-Claude%20Code%20%7C%20Codex%20%7C%20Cursor%20%7C%20Gemini%20%7C%20Copilot-brightgreen) ![Indent](https://img.shields.io/badge/indent-Tab-orange) ![Comments](https://img.shields.io/badge/comments-%E4%B8%AD%E6%96%87-red)

</div>

Charles 专用的全栈编码规范，适用于主流 AI 编程工具。

覆盖 Java / Kotlin / Python / Go / TypeScript / JavaScript / HTML / CSS / SQL / Node.js / Vue 3 / React / Android / Web 前端，包含：分层架构与解耦、命名与注释、变更类型闸门、测试要求、Git 分支与交付规范，以及一个会 fail 的规范校验器。

## 组成

七个 skill，一份规范本体加六个场景工作流：

| skill | 用途 |
| --- | --- |
| `coding-standards` | 规范本体：交付红线、场景路由、规范模块索引 |
| `new-project` | 新项目初始化：装脚手架、装闸门、验证闸门确实会 fail |
| `legacy-project` | 老项目接入：增量检查，新代码严格、存量不阻塞 |
| `new-feature` | 新功能与需求变更：问清需求、模块文档评审、编码、测试 |
| `bugfix` | Bug 修复：定位根因、先写复现测试、再改实现 |
| `refactor` | 重构：证明行为等价，禁止改断言让它通过 |
| `review` | 代码审查：先跑校验器，再审脚本查不了的部分 |

## 安装

### Claude Code
```bash
git clone git@github.com:CharlesHYF/charles-coding-skill.git ~/.claude/plugins/charles-coding
```
在 `~/.claude/settings.json` 里把它加入 marketplace，或直接把 `skills/` 下各目录软链到 `~/.claude/skills/`。

### Codex CLI
```bash
git clone git@github.com:CharlesHYF/charles-coding-skill.git ~/.agents/plugins/charles-coding
```

### Cursor
```bash
git clone git@github.com:CharlesHYF/charles-coding-skill.git .cursor/plugins/charles-coding
```

### Gemini CLI
```bash
git clone git@github.com:CharlesHYF/charles-coding-skill.git ~/.gemini/extensions/charles-coding
```
扩展清单为仓库根的 `gemini-extension.json`，上下文文件为 `AGENTS.md`。

### 其它工具（OpenCode / Trae / Qoder / Rovo Dev / Copilot）
这些工具按 skill 目录加载，把 `skills/` 下需要的目录复制或软链到对应位置：
```bash
git clone git@github.com:CharlesHYF/charles-coding-skill.git ~/charles-coding-skill
ln -s ~/charles-coding-skill/skills/coding-standards ~/.<工具>/skills/charles-coding
```

### Hermes Agent / OpenClaw
无需安装目录，把 `skills/coding-standards/SKILL.md` 内容作为 system prompt 注入即可。

## 更新
```bash
cd <安装目录> && git pull origin main
```

## 目录结构
```
.
├── skills/
│   ├── coding-standards/         # 规范本体
│   │   ├── SKILL.md              # 交付红线 + 场景路由 + 模块索引
│   │   ├── rules/                # 通用规则，所有语言适用
│   │   │   ├── common.md         # 缩进、行尾、禁用符号、大括号、换行、常量
│   │   │   ├── naming.md         # 变量、函数、布尔、集合、数据传输对象
│   │   │   ├── text.md           # 注释语法、文件头、篇幅、折行、措辞
│   │   │   ├── architecture.md   # 分层架构、解耦、单一入口、文件内组织
│   │   │   ├── git.md            # 提交、署名、分支、gitignore、交付整洁
│   │   │   ├── process.md        # 变更类型闸门表、模块文档、子 Agent 契约
│   │   │   └── collaboration.md  # 工作节奏、确认边界、中文表达
│   │   ├── languages/            # java kotlin python go javascript-typescript html-css sql
│   │   ├── stacks/               # vue react nodejs web android
│   │   └── domains/              # testing logging devops ai-ml docs-markdown
│   ├── new-project/              # 六个场景工作流
│   ├── legacy-project/
│   ├── new-feature/
│   ├── bugfix/
│   ├── refactor/
│   └── review/
├── tools/
│   ├── check.sh                  # 规范校验器，八项检查，会 fail
│   └── install-check.sh          # 老项目接入安装器
├── templates/
│   ├── project-template/         # 新项目脚手架
│   ├── module-doc.md             # 模块文档模板
│   └── examples/                 # 测试用例与模块文档范例、前端范例页
├── tests/                        # 本仓自测（CI 强制）
└── .claude-plugin/ .cursor-plugin/ .codex-plugin/ .agents/   # 各工具适配层
```

## 规范校验器

`tools/check.sh` 把确定性规则变成会 fail 的检查，共八项：

```bash
bash tools/check.sh --all        # 全量扫描
bash tools/check.sh --changed    # 只查本次改动（老项目与日常迭代用）
```

| 检查 | 内容 |
| --- | --- |
| 一 | 禁用字符（Unicode 引号、破折号、Emoji） |
| 二 | 源码文件头注释块（作用描述、创建日期、修改日期、全角冒号） |
| 三 | 项目必需文件与 `docs/modules/`、`test_cases/` 目录层级 |
| 四 | 命名（数据传输对象后缀、占位名、编号名、口语函数名） |
| 五 | 注释语法（块注释三段式、docstring 引号） |
| 六 | 注释篇幅（**硬上限 3 行**）与句子折断 |
| 七 | 注释黑话（隐喻与口语表达词表） |
| 八 | 模块访问边界（单一入口，读项目根 `.import-boundaries`） |

两级豁免：文件级写进 `.checkignore`，行级在注释里加 `check-ignore` 标记。文档反例与测试 fixture 用它放行。

## 交付闸门

```
push agents/**   ->  pre-push 钩子跑增量校验
push main        ->  pre-push 钩子跑全量 make verify，不过不让推
推到远端之后      ->  云端 CI 二次确认
```

本地 pre-push 钩子是真闸门，云端 CI 拦的是钩子被绕过或未安装的情况。钩子由 `scripts/setup.sh` 或 `tools/install-check.sh` 安装。

## 仓库自测（本仓 CI 强制）

规范仓对自己执行同一套标准，`.github/workflows/test.yml` 在 push 与 PR 时强制跑四项：

```bash
bash tests/run_tests.sh          # check.sh 回归测试，46 项断言
bash tests/check_consistency.sh  # 多处同源规则一致性，50 项断言
bash tests/check_structure.sh    # skill 完整性、六处版本号、Markdown 死链
bash tools/check.sh --all        # 规范仓自身的规范校验
```

回归测试既断言该报的都报，也断言不该报的不报（CSS 自定义属性、JS 自减、URL 双斜杠、多参数 Javadoc、框架基类命名、业务术语），误报会让闸门被绕过，和漏报一样严重。

## 核心约定（速览）

| 项目 | 规范 |
| --- | --- |
| 缩进 | Tab（Python / Kotlin 4 空格，SQL / YAML / JSON 2 空格） |
| 行尾 | 统一 LF |
| 大括号 | 控制流与函数体必须用 `{}`，前后留空行 |
| 常量 | 禁止魔法数字，必须定义为顶部具名常量 |
| 命名 | 见名知义；禁止占位名（`tmp` / `obj`）、编号名（`data1`）、拼音混拼（`getYonghu`）、隐喻口语名（`doIt`）；函数名 = 动词 + 名词，动词全项目统一 |
| 文件头 | 三行：第一行直接写具体职责（无前缀标签、句尾不加句号），第二三行 `创建日期：` / `修改日期：`，冒号必须中文全角 |
| 注释篇幅 | 正文默认 1-2 行，**硬上限 3 行**（标签行不计入）；一条注释一行写完，禁止把一句话折断换行 |
| 注释语法 | 多行注释一律用块或文档注释，禁止连续多行 `//` / `#` 拼多行；Go 声明级注释按官方标准用 `//` |
| 注释措辞 | 动作加对象加必要条件，一句话说清；动作词全项目统一；禁止隐喻黑话；日志与用户可见文案同一套要求 |
| 分层架构 | 后端强制 Controller 到 Service 到 Repository，禁止跨层 |
| 单一入口 | 一项能力只暴露一个入口模块，底层实现不许被入口之外的地方直接 import；受保护关系写进 `.import-boundaries` |
| 变更闸门 | 动手前先判定变更类型（新功能 / 需求变更 / Bug 修复 / 重构 / 依赖升级），按对应档执行文档与测试要求 |
| Bug 修复 | 先定位根因，**先写复现测试并确认它失败**，再改实现，测试保留进 `regression/` |
| 重构 | 必须证明行为等价，禁止修改断言、删用例、放宽阈值让它通过 |
| 模块文档 | `docs/modules/<系统模块>/<模块名>.md` 两级组织，新功能编码前先写文档并评审 |
| 测试目录 | `test_cases/<系统模块>/<测试类型>/` 两级组织 |
| CI | push main 与 PR 走全量，push `agents/**` 走增量；校验范围为禁用字符/文件头/注释语法/注释篇幅/注释黑话/必需文件/命名/模块边界，外加提交信息扫描 |
| Git 作者 | `Charles <w1400214654@outlook.com>`，禁止任何 AI 联合署名 |
| Git 分支 | AI 提交到 `agents/feature/xxx`，不直接推主干、不发起 PR |

完整细则见 [skills/coding-standards/SKILL.md](skills/coding-standards/SKILL.md)。

## 新项目与老项目

```bash
# 新项目：复制脚手架
cp -r templates/project-template/ <新项目路径>

# 老项目：装增量校验器与 pre-push 钩子
bash tools/install-check.sh <项目路径>
```

老项目接入后默认走增量检查，存量违规不阻塞交付，新增代码按完整标准执行。详细步骤见 `skills/legacy-project/SKILL.md`。

## 遵从率兜底

Skill 靠 description 软触发。为兜底老项目被忽略或不确认就改的情况，可在 `~/.claude/settings.json` 配置 SessionStart hook，每次会话开始注入固定提醒：

```json
{
  "hooks": {
    "SessionStart": [
      { "hooks": [ { "type": "command", "command": "cat ~/.claude/charles-coding-reminder.txt" } ] }
    ]
  }
}
```

提醒文本三条：老项目无 AGENTS.md 先确认需求；新功能先写模块文档并评审再编码；交付前测试必须实跑通过。新增后需新开会话生效。
