# Charles Coding — 文档与 Markdown 规范
<!--
作用：README / 徽章 / Markdown 规范分册，从 SKILL.md 下沉迁移
创建日期：2026-07-29
-->
> charles-coding 文档规范分册。先遵循 [SKILL.md](../SKILL.md)。

### Markdown 规范
- **严禁**使用 `---` / `***` / `___` 等任何形式的分割线（水平线）
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
