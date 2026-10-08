# Charles Coding -- Git 规范
> 提交信息、署名、分支权限、.gitignore 与交付整洁。

## Git 规范
| 项目       | 规范                                      |
| ---------- | ----------------------------------------- |
| 作者       | 仓库使用者本人的 git 身份，以 `git config user.name` / `user.email` 为准 |
| 提交信息   | 符合社区常规（建议 Conventional Commits） |
| 署名归属   | 仅署名使用者本人，**禁止**任何 AI 联合署名 |

## 提交粒度
> **一个任务、一个需求、一个问题，对应一个 commit。**

- 多个不相干的改动不许塞进同一次提交；一个改动跨多个文件是正常的，一次提交跨多个需求不是
- **重构与功能修改分开提交**，混在一起就无法单独回滚，也看不清哪些行是行为变更
- 纯格式化的批量改动单独一个提交，信息里注明"仅格式化，无行为变更"，并把该提交哈希登记进 `.git-blame-ignore-revs`
- 提交信息正文写清做了什么、为什么，不写"修复 bug"这类无信息内容
- 判据：如果一次提交的信息需要用"同时还"、"顺便"来连接，说明它应该被拆开

## .gitignore 规范
- **所有 Git 项目必须包含 `.gitignore`**，覆盖以下常见忽略项（不限于此，按项目实际补充）：
  - **IDE / 编辑器**：`.idea/`、`.vscode/`、`*.swp`、`*.swo`、`*~`
  - **AI 工具残留**：`.claude/`、`.cursor/`、`.codex/`、`.agents/`、`.opencode/` 等 AI 工具在项目里生成的本地目录
  - **操作系统**：`.DS_Store`（macOS）、`Thumbs.db`（Windows）、`Desktop.ini`（Windows）、`*.lnk`（Windows）
  - **依赖与构建**：`node_modules/`、`vendor/`、`__pycache__/`、`*.pyc`、`target/`（Java）、`dist/`、`build/`
  - **运行时**：`.env`、`.env.local`、`*.log`、`*.pid`、`coverage/`
- 脚手架模板 `../../../templates/project-template/.gitignore` 已包含上述常见项，新项目直接复制为起点，再按语言/框架追加

## 禁止 AI 署名（commit/push 时必须遵守）
> **目的**：避免 GitHub 上出现 `claude` / Agent 作为提交者或 contributor（如 "someone and claude" 的联合署名）。

- **禁止** 在提交信息中添加任何 AI 联合署名 trailer，包括但不限于：
  - `Co-Authored-By: Claude <noreply@anthropic.com>`
  - `Co-Authored-By: <任何 AI / Agent / Bot>`
  - 末尾的 `Generated with ...` 之类的 AI 生成声明
- **禁止** 把 author / committer 设为 Agent 或 AI 身份；author 与 committer 必须始终是使用者本人在本机配置的 git 身份
- 提交前确认 `git config user.name` 与 `user.email` 已配置且是使用者本人；未配置时停下来请使用者配置，**禁止**自行编造或改写成其他人的身份
- 提交信息正文只描述"做了什么、为什么"，不出现任何 AI / 工具相关的署名或水印

## Git 分支与 AI 协作权限
- **主分支**：`main`（或其他主干分支），仅由使用者本人合并或发起 Pull Request
- **AI 工作区**：所有 AI 生成的代码必须提交到 `agents/feature/xxx` 分支，**禁止**直接提交到主干或发起 PR
- **工作流**：
  1. AI 在 `agents/feature/xxx` 分支上开发并 commit
  2. 使用者本人审查代码后，手动合并到 `main` 或通过 PR 合入
  3. AI 不参与代码审查和合并操作

## 交付整洁规范
- **交付时严禁残留无用文件**：临时脚本、调试文件、废弃代码、空目录、`xxx-copy`/`xxx备份`、注释掉的大段代码等一律清理，交付物只保留真正需要的文件
- **过程产物禁止 commit**：开发过程中产生的 `spec`、`plan`、设计草稿、调研笔记、Agent 中间产物等**禁止提交到仓库**，一律写入 `.gitignore`（如 `*.spec.md`、`plan/`、`.agent/`、`scratch/` 等按项目约定），只提交最终代码与正式文档（`docs/`、`README`、`test_cases/`）

