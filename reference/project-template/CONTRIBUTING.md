# 贡献指南

## 分支策略
- `main`：稳定分支，仅 Charles 本人直接提交或合并 PR
- `agents/feature/<描述>`：AI 辅助开发的工作分支，AI 只能提交到此命名空间
- 功能分支（人工）：`feature/<描述>`，由 Charles 创建和管理

## AI 协作边界
- AI 助手只能在 `agents/` 开头的分支上生成代码和提交
- 禁止 AI 直接推送到 `main` 或发起 Pull Request
- 所有 AI 产出需经 Charles 审查后手动合并

## 提交规范
- 遵循 Conventional Commits，例如：
  - `feat: add user login API`
  - `fix: resolve null pointer in order service`
  - `docs: update API documentation`
- 作者信息固定为： Charles w1400214654@outlook.com 

## 代码审查要点
- 检查注释是否完整（文件头注释、函数注释）
- 是否启用了代码格式化工具
- 测试覆盖率是否达标（Python ≥80%）
- 安全相关：SQL 参数化、输入校验等

## 本地开发
- 使用 Docker Compose 启动依赖服务
- 各语言环境按技能说明书（SKILLS.md）配置