# charles-coding-skill
![Version](https://img.shields.io/badge/version-2.11.0-blue) ![Languages](https://img.shields.io/badge/languages-Java%20%7C%20Kotlin%20%7C%20Go%20%7C%20Vue3%20%7C%20React%20%7C%20Python%20%7C%20SQL-informational) ![AI Tools](https://img.shields.io/badge/AI%20tools-Claude%20Code%20%7C%20Codex%20%7C%20Cursor%20%7C%20Gemini%20%7C%20Copilot-brightgreen) ![Indent](https://img.shields.io/badge/indent-Tab-orange) ![Comments](https://img.shields.io/badge/comments-%E4%B8%AD%E6%96%87-red)

	Charles 专用全栈编码规范 Skill，适用于主流 AI 编程工具。

	覆盖 Java / Kotlin / Go / Vue 3 / React / Python / SQL，包含：Tab 缩进、中文注释、文件头规范、命名约定、格式化工具链、测试要求、Git 分支与提交规范。

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
