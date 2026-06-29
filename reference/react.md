# Charles Coding — React

> charles-coding 的 React 分册。**先遵循 [SKILL.md](../SKILL.md) 的「全局约定」。**

## 能力范围
- 单页应用、SSR/SSG 全栈应用、高交互性后台

## 技术栈（最优组合）
- 框架：Next.js 14+ (App Router)，SSR 优先
- 类型：TypeScript 严格模式
- 状态管理：Zustand（轻量全局态），React Context 仅用于主题/鉴权等少数场景
- 数据请求：TanStack Query (React Query) + axios
- 表单：React Hook Form + Zod 校验
- UI 方案：Tailwind CSS + shadcn/ui，构建可复用组件库
- 路由：Next.js 文件系统路由，动态路由采用 `[slug]` 形式

## 代码风格
- 组件：函数式组件 + Hooks
- 文件结构：按功能/领域（feature-based）组织，页面置于 `app/` 下，组件归于 `components/`
- 客户端组件：仅在必要时添加 `'use client'`，数据获取优先在服务端组件中进行
- 样式：Tailwind 优先，复杂样式抽取为自定义组件
- 格式化：Prettier + ESLint（或 Biome 一把梭）；用 Prettier 时设 `useTabs: true`，用 Biome 时设 `indentStyle: tab`

## 测试
- 单元 / 组件测试：Vitest + @testing-library/react
- E2E 测试：Playwright
- 默认要求关键路径和公共组件有测试覆盖
