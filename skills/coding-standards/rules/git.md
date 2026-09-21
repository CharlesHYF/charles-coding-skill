# Charles Coding -- Git 规范
> 提交信息、署名、分支权限、.gitignore 与交付整洁。

## Git 规范
| 项目       | 规范                                      |
| ---------- | ----------------------------------------- |
| 作者       | Charles <w1400214654@outlook.com>         |
| 提交信息   | 符合社区常规（建议 Conventional Commits） |
| 署名归属   | 仅署名 Charles，**禁止**任何 AI 联合署名  |

## .gitignore 规范
- **所有 Git 项目必须包含 `.gitignore`**，覆盖以下常见忽略项（不限于此，按项目实际补充）：
  - **IDE / 编辑器**：`.idea/`、`.vscode/`、`*.swp`、`*.swo`、`*~`
  - **AI 工具残留**：`.claude/`、`.cursor/`、`.codex/`、`.agents/`、`.opencode/` 等 AI 工具在项目里生成的本地目录
  - **操作系统**：`.DS_Store`（macOS）、`Thumbs.db`（Windows）、`Desktop.ini`（Windows）、`*.lnk`（Windows）
  - **依赖与构建**：`node_modules/`、`vendor/`、`__pycache__/`、`*.pyc`、`target/`（Java）、`dist/`、`build/`
  - **运行时**：`.env`、`.env.local`、`*.log`、`*.pid`、`coverage/`
- 脚手架模板 `../../../templates/project-template/.gitignore` 已包含上述常见项，新项目直接复制为起点，再按语言/框架追加

## 禁止 AI 署名（commit/push 时必须遵守）
> **目的**：避免 GitHub 上出现 `claude` / Agent 作为提交者或 contributor（如 "CharlesHYF and claude" 的联合署名）。

- **禁止** 在提交信息中添加任何 AI 联合署名 trailer，包括但不限于：
  - `Co-Authored-By: Claude <noreply@anthropic.com>`
  - `Co-Authored-By: <任何 AI / Agent / Bot>`
  - 末尾的 `Generated with ...` 之类的 AI 生成声明
- **禁止** 把 author / committer 设为 Agent 或 AI 身份；author 与 committer 必须始终为 `Charles <w1400214654@outlook.com>`
- 提交前确认 `git config user.name` = `Charles`、`user.email` = `w1400214654@outlook.com`；必要时用 `git commit --author="Charles <w1400214654@outlook.com>"` 显式指定
- 提交信息正文只描述"做了什么、为什么"，不出现任何 AI / 工具相关的署名或水印

## Git 分支与 AI 协作权限
- **主分支**：`main`（或其他主干分支），仅由 Charles 本人合并或发起 Pull Request
- **AI 工作区**：所有 AI 生成的代码必须提交到 `agents/feature/xxx` 分支，**禁止**直接提交到主干或发起 PR
- **工作流**：
  1. AI 在 `agents/feature/xxx` 分支上开发并 commit
  2. Charles 审查代码后，手动合并到 `main` 或通过 PR 合入
  3. AI 不参与代码审查和合并操作

## 交付整洁规范
- **交付时严禁残留无用文件**：临时脚本、调试文件、废弃代码、空目录、`xxx-copy`/`xxx备份`、注释掉的大段代码等一律清理，交付物只保留真正需要的文件
- **过程产物禁止 commit**：开发过程中产生的 `spec`、`plan`、设计草稿、调研笔记、Agent 中间产物等**禁止提交到仓库**，一律写入 `.gitignore`（如 `*.spec.md`、`plan/`、`.agent/`、`scratch/` 等按项目约定），只提交最终代码与正式文档（`docs/`、`README`、`test_cases/`）

