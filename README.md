# charles-coding-skill

Charles 专用全栈编码规范 —— 适用于 Claude Code / Superpowers Skill 体系。

## 安装

```bash
git clone git@github.com:CharlesHYF/charles-coding-skill.git ~/.claude/skills/charles-coding
```

克隆到 `~/.claude/skills/charles-coding` 后，Claude Code 即可自动识别并加载该 Skill。

**更新到最新版本：**

```bash
cd ~/.claude/skills/charles-coding && git pull origin main
```

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

## 快速上手

| 领域 | 分册 |
|------|------|
| Java / Spring Boot | [reference/java.md](reference/java.md) |
| Kotlin / Android | [reference/kotlin-android.md](reference/kotlin-android.md) |
| Go / Gin | [reference/go.md](reference/go.md) |
| Vue 3 | [reference/vue.md](reference/vue.md) |
| React / Next.js | [reference/react.md](reference/react.md) |
| Python / FastAPI | [reference/python.md](reference/python.md) |
| SQL | [reference/sql.md](reference/sql.md) |

## 核心约定（速览）

- **缩进**：Tab（Python / Kotlin 例外用 4 空格，SQL / YAML / JSON 用 2 空格）
- **行尾**：统一 LF
- **编码**：UTF-8
- **注释语言**：中文
- **文件头**：所有源码文件顶部注明文件作用 + 创建日期
- **Git 作者**：`Charles <w1400214654@outlook.com>`，禁止 AI 联合署名

详见 [SKILL.md](SKILL.md)。

## 新项目脚手架

复制 [`reference/project-template/`](reference/project-template/) 作为新项目起点，内含 `.editorconfig` / `.gitattributes` / `.gitignore` / `Makefile` / `scripts/`。
