# charles-coding-skill -- AI 工作指令

本仓是 Charles 的编码规范本体。**改这个仓库时，同样遵守它自己定义的规范**。

## 这是什么

一个跨工具的编码规范 plugin，包含七个 skill：

| skill | 作用 |
| --- | --- |
| `skills/charles-coding-standards/` | 规范本体：场景路由、交付红线、规范模块索引 |
| `skills/charles-coding-new-project/` | 新项目初始化工作流 |
| `skills/charles-coding-legacy-project/` | 老项目接入工作流 |
| `skills/charles-coding-new-feature/` | 新功能与需求变更工作流 |
| `skills/charles-coding-bugfix/` | Bug 修复工作流 |
| `skills/charles-coding-refactor/` | 重构工作流 |
| `skills/charles-coding-review/` | 代码审查工作流 |

规范细则在 `skills/charles-coding-standards/` 下的 `rules/`（通用规则）、`languages/`（语言）、`stacks/`（技术栈）、`domains/`（领域）。

## 交付红线

1. **改完必须跑通三项验证**，缺一不可：
   ```bash
   bash tests/run_tests.sh
   bash tests/check_consistency.sh
   bash tests/check_structure.sh
   ```
2. 改了 `tools/check.sh` 必须同步 `templates/project-template/scripts/check.sh`，两份内容必须逐字一致（一致性测试会校验）
3. 改了规则文本，检查 `tests/check_consistency.sh` 里对应的同源断言是否还成立
4. 新增规则时优先考虑能否被 `tools/check.sh` 机器验证，不能验证的写进"手动约定类"并如实标注
5. 版本号出现在六处，必须同步：`skills/charles-coding-standards/SKILL.md`、四个 plugin 配置、`gemini-extension.json`（结构校验会比对）

## 硬约束（本仓自身适用）

- 注释中文，源码文件头三行：作用描述、`创建日期：YYYY-MM-DD`、`修改日期：YYYY-MM-DD`，冒号全角
- Shell 缩进用 Tab，行尾 LF
- 禁用 Unicode 弯引号、破折号、Emoji，统一半角与 `--`
- 注释块正文不超过 3 行，一条注释一行写完
- 文档里需要展示违规写法时，该文件必须进 `.checkignore`，或在该行加 `check-ignore` 标记
- 提交到 `agents/feature/*` 分支，**禁止任何 AI 联合署名**，author 与 committer 必须是提交者本人的 git 身份

## 常用命令

```bash
bash tools/check.sh --all          # 全量规范校验
bash tools/check.sh --changed      # 只查本次改动
bash tests/run_tests.sh            # check.sh 回归测试
bash tests/check_consistency.sh    # 多处同源规则一致性
bash tests/check_structure.sh      # 目录结构、版本号与链接
```

## 修改边界

- 规则文本与校验器是同源的：改了规则必须同步改校验器与测试，只改一边等于制造分叉
- 不要在 `skills/charles-coding-standards/SKILL.md` 里堆细则，它只放路由、红线和索引，细则下沉到对应模块
- 第三方 skill 或工具的名称不写进规范正文
