<h1 align="center">charles-coding-skill</h1>
<div align="center">

![Version](https://img.shields.io/badge/version-3.4.0-blue) ![Languages](https://img.shields.io/badge/languages-Java%20%7C%20Kotlin%20%7C%20Go%20%7C%20Vue3%20%7C%20React%20%7C%20Python%20%7C%20SQL-informational) ![AI Tools](https://img.shields.io/badge/AI%20tools-Claude%20Code%20%7C%20Codex%20%7C%20Cursor%20%7C%20Gemini%20%7C%20Copilot-brightgreen) ![Indent](https://img.shields.io/badge/indent-Tab-orange) ![Comments](https://img.shields.io/badge/comments-%E4%B8%AD%E6%96%87-red)

</div>

Charles 专用全栈编码规范 Skill，适用于主流 AI 编程工具。

覆盖 Java / Kotlin / Go / Vue 3 / React / Python / SQL，包含：分层架构、解耦原则、代码块规范、命名约定、常量管理、格式化工具链、Docker 规范、测试要求、Git 分支与提交规范、注释规范。

## 安装
### Claude Code
```bash
# 全局（推荐，对所有项目生效）
git clone git@github.com:CharlesHYF/charles-coding-skill.git ~/.claude/skills/charles-coding

# 项目级
git clone git@github.com:CharlesHYF/charles-coding-skill.git .claude/skills/charles-coding
```

### Codex CLI
```bash
# 全局
git clone git@github.com:CharlesHYF/charles-coding-skill.git ~/.agents/skills/charles-coding

# 项目级
git clone git@github.com:CharlesHYF/charles-coding-skill.git .agents/skills/charles-coding
```

### OpenCode
```bash
git clone git@github.com:CharlesHYF/charles-coding-skill.git .opencode/skills/charles-coding
```

### Cursor
```bash
git clone git@github.com:CharlesHYF/charles-coding-skill.git .cursor/skills/charles-coding
```

### Gemini CLI
```bash
git clone git@github.com:CharlesHYF/charles-coding-skill.git .gemini/skills/charles-coding
```

### GitHub Copilot
```bash
git clone git@github.com:CharlesHYF/charles-coding-skill.git .github/skills/charles-coding
```

### Trae
```bash
# 国际版
git clone git@github.com:CharlesHYF/charles-coding-skill.git ~/.trae/skills/charles-coding

# 国内版
git clone git@github.com:CharlesHYF/charles-coding-skill.git ~/.trae-cn/skills/charles-coding
```

### Rovo Dev
```bash
# 全局
git clone git@github.com:CharlesHYF/charles-coding-skill.git ~/.rovodev/skills/charles-coding

# 项目级
git clone git@github.com:CharlesHYF/charles-coding-skill.git .rovodev/skills/charles-coding
```

### Qoder
```bash
# 全局
git clone git@github.com:CharlesHYF/charles-coding-skill.git ~/.qoder/skills/charles-coding

# 项目级
git clone git@github.com:CharlesHYF/charles-coding-skill.git .qoder/skills/charles-coding
```

### Pi
```bash
git clone git@github.com:CharlesHYF/charles-coding-skill.git .pi/skills/charles-coding
```

### Hermes Agent / OpenClaw
无需手动安装目录，将 [SKILL.md](SKILL.md) 内容作为 system prompt 或上下文注入即可。

## 更新
```bash
cd <上述安装目录> && git pull origin main
```

## 目录结构
```
.
├── SKILL.md                      # Skill 主入口：全局约定 + 速查索引
├── example.html                  # 完整前端范例（展会落地页，含网格布局/自定义下拉/Toast）
└── reference/
    ├── java.md                   # Java / Spring Boot
    ├── kotlin-android.md         # Kotlin / Android
    ├── go.md                     # Go / Gin
    ├── vue.md                    # Vue 3 / Vite
    ├── react.md                  # React / Next.js
    ├── python.md                 # Python / FastAPI
    ├── sql.md                    # SQL (PostgreSQL / MySQL / SQLite)
    ├── module-doc-template.md    # 模块文档模板
    ├── readme-md.md              # 文档与 Markdown 规范
    ├── devops.md                 # DevOps 与部署安全
    ├── testing.md                # 测试与压测
    ├── logging.md                # 日志
    ├── ai-ml.md                  # AI / ML
    ├── examples/                 # 详细范例（测试用例 + 模块文档，仅参考不复制）
    │   ├── test_cases/           # backend / frontend / daemon 三级模块测试用例范例
    │   └── docs/modules/         # backend / frontend / daemon 三级模块文档范例
    └── project-template/         # 新项目脚手架骨架
```

## 核心约定（速览）
| 项目 | 规范 |
|------|------|
| 缩进 | Tab（Python / Kotlin 4 空格，SQL / YAML / JSON 2 空格） |
| 行尾 | 统一 LF |
| 大括号 | 控制流/函数体必须用 `{}`，前后留空行 |
| 常量 | 禁止魔法数字，必须定义为顶部具名常量 |
| 命名 | 见名知义，禁止 `o`/`n`/`tmp` 等无意义变量名 |
| 文件头 | 三行：**第一行直接写作用描述**（一到两句话，**无前缀标签、句尾不加句号**），第二三行 `创建日期：` / `修改日期：`，**冒号必须中文全角**；由 `scripts/check.sh` 拦截 |
| 注释篇幅 | 正文默认 1-2 行，**硬上限 3 行**（`@param` 等标签行不计入）；背景推演、方案权衡、故障复盘写进 `docs/modules/` 而非注释；由 `scripts/check.sh` 拦截 |
| 注释语法 | **多行注释一律用块/文档注释**（Java/Kotlin/JS/TS `/** */`、Python `"""` docstring、Vue/HTML `<!-- -->`、SQL `/* */`），禁止连续多行 `//` / `#` 拼多行；单行说明才用 `//` / `#`。例外：Go 声明级注释按 Go doc 标准用 `//`；Shell/YAML/Dockerfile 无块注释语法只能用 `#`。由 `scripts/check.sh` 拦截 |
| 注释 | 中文；文件头只写作用不写实现；块注释/docstring 三段式（首末行独占）；Python docstring 统一双引号 `"""`，禁止单引号三引号，禁止把单行说明写成三引号字符串；说明性注释置于被说明对象上方 |
| 禁用符号 | 禁止各类 Unicode 引号/破折号变体（弯引号 / CJK 角引号 / 全角引号 / em / en dash 等），统一用半角 `""` / `--`；由 `scripts/check.sh` 拦截 |
| 测试目录 | `test_cases/<系统模块>/<测试类型>/` 两级组织，每个 func 都要写测试用例 |
| 模块文档 | `docs/modules/<系统模块>/<模块名>.md` 两级组织，编码前先写文档 |
| 分层架构 | 所有后端项目 Controller → Service → Repository |
| 解耦 | 非必要不耦合，禁止循环依赖，重复代码必须抽离 |
| Docker | 强制 compose，`./volumes/` 持久化，东八区 |
| 测试 | 交付必须附带 `test_cases/`，确保通过；`scripts/test.sh` 零测试判失败（`ALLOW_NO_TESTS=1` 逃生舱） |
| CI | `.github/workflows/verify.yml`：push `agents/feature/**` 或 PR→main 跑 `make lint` + 测试 + 提交信息扫描（破折号/Emoji/AI 署名） |
| Git 作者 | `Charles <w1400214654@outlook.com>`，禁止 AI 联合署名 |
| Git 分支 | AI 提交到 `agents/feature/xxx`，不直接推主干 |
| .gitignore | 必须覆盖 IDE（`.idea/`）、AI 工具（`.claude/` 等）、OS 残留 |

详见 [SKILL.md](SKILL.md)。

## 遵从率兜底 · SessionStart Hook
Skill 靠 description 软触发，为兜底"老项目被忽略/不确认就改"，可在本机 `~/.claude/settings.json` 配置一个 SessionStart hook，每次会话开始注入固定提醒（非阻断）。

配置步骤：
1. 新建提醒文本 `~/.claude/charles-coding-reminder.txt`，内容为三条：老项目无 AGENTS.md 先确认；新功能/新模块先写 docs/modules 文档评审再编码，小改/bugfix 豁免但需 commit 说明；交付前测试必须实跑通过。
2. 在 `~/.claude/settings.json` 的 `hooks.SessionStart` 加一条 command hook：`cat ~/.claude/charles-coding-reminder.txt`。

```json
{
  "hooks": {
    "SessionStart": [
      { "hooks": [ { "type": "command", "command": "cat ~/.claude/charles-coding-reminder.txt" } ] }
    ]
  }
}
```

新增后需新开会话或在 Claude Code 打开一次 /hooks 使其加载。

## 新项目脚手架
复制 [`reference/project-template/`](reference/project-template/) 作为新项目起点，内含 `.editorconfig` / `.gitattributes` / `.gitignore` / `Makefile` / `scripts/` / `.github/workflows/verify.yml`（CI）/ `test_cases/` 骨架 / `docs/modules/` 骨架。详细范例见 [`reference/examples/`](reference/examples/)。
