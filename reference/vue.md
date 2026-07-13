# Charles Coding — Vue

> charles-coding 的 Vue 分册。**先遵循 [SKILL.md](../SKILL.md) 的「全局约定」。**

## 能力范围
- 单页应用、后台管理系统、移动端适配页面

## 技术栈与工具
- 版本：Vue 3 + Composition API
- 类型：TypeScript 严格模式
- 构建：Vite
- 状态管理：Pinia（开启持久化插件）
- 路由：Vue Router **history 模式**（`createWebHistory`），使用导航守卫检查登录状态；部署到不支持 URL rewrite 的静态托管时才退回 hash 模式
- UI 库：Element Plus、Ant Design Vue、Vuetify 按场景选用，亦会搭配 Tailwind CSS 快速原型
- 数据请求：axios 封装（统一拦截、错误处理、token 注入）
- 常用组合函数：`useAuth`、`useRequest`、`usePermission` 等

## 代码风格
- 单文件组件顺序：`<template>` → `<script setup lang="ts">` → `<style scoped>`
- **文件头注释块**：SFC 只在 **`<script setup lang="ts">` 顶部**写一次（含文件作用、创建日期、修改日期，见 [SKILL.md](../SKILL.md) 注释规范）。**禁止**在 `<template>` 之前的 HTML 注释里重复书写，避免一份文件头出现两处。
- 样式方案：优先 Tailwind CSS，必要时用 `<style scoped>` 补充组件私有样式
- 格式化：Prettier + ESLint（eslint-plugin-vue）；Prettier 设 `useTabs: true` 以符合全局 Tab 约定

## 测试
- 单元测试：Vitest + Vue Test Utils（关键路径与公共组件必测）
- E2E 测试：Playwright
