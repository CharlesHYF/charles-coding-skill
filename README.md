# charles-coding-skill

Charles 专用全栈编码规范，适用于 Claude Code（Superpowers Skill 体系）。

覆盖 Java / Kotlin / Go / Vue 3 / React / Python / SQL，包含：Tab 缩进、中文注释、文件头规范、命名约定、格式化工具链、测试要求、Git 分支与提交规范。

## 安装

### 方式一：全局安装（推荐）

将 skill 克隆到 Claude Code 的全局 skills 目录，对所有项目生效：

```bash
git clone git@github.com:CharlesHYF/charles-coding-skill.git ~/.claude/skills/charles-coding
```

### 方式二：项目级安装

仅对当前项目生效，适合团队共享：

```bash
# 在项目根目录执行
git clone git@github.com:CharlesHYF/charles-coding-skill.git .claude/skills/charles-coding
```

或以 Git Submodule 方式引入，方便跟随上游更新：

```bash
git submodule add git@github.com:CharlesHYF/charles-coding-skill.git .claude/skills/charles-coding
```

### 安装后使用

在 Claude Code 中直接调用：

```
/charles-coding
```

或在对话中描述任务，skill 会根据 `~/.claude/CLAUDE.md` 的配置自动触发。

### 更新

```bash
cd ~/.claude/skills/charles-coding && git pull origin main
```

---

## 目录结构

```
.
├── SKILL.md                  # Skill 主入口：全局约定 + 速查索引
└── reference/
    ├── java.md               # Java / Spring Boot
    ├── kotlin-android.md     # Kotlin / Android
    ├── go.md                 # Go / Gin
    ├── vue.md                # Vue 3 / Vite
    ├── react.md              # React / Next.js
    ├── python.md             # Python / FastAPI
    ├── sql.md                # SQL (PostgreSQL / MySQL / SQLite)
    └── project-template/     # 新项目脚手架模板
```

## 核心约定（速览）

| 项目 | 规范 |
|------|------|
| 缩进 | Tab（Python / Kotlin 4 空格，SQL / YAML / JSON 2 空格） |
| 行尾 | 统一 LF |
| 注释语言 | 中文 |
| 文件头 | 所有源码文件注明作用 + 创建日期 |
| Git 作者 | `Charles <w1400214654@outlook.com>`，禁止 AI 联合署名 |
| AI 分支 | 提交到 `agents/feature/xxx`，不直接推主干 |

详见 [SKILL.md](SKILL.md)。

## 新项目脚手架

复制 [`reference/project-template/`](reference/project-template/) 作为新项目起点，内含 `.editorconfig` / `.gitattributes` / `.gitignore` / `Makefile` / `scripts/`。
