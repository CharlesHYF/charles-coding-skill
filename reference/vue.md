# Charles Coding -- Vue
> charles-coding 的 Vue 分册。**先遵循 [SKILL.md](../SKILL.md) 的"全局约定"。**

## 能力范围
- 单页应用、后台管理系统、移动端适配页面

## 技术栈与工具
- 版本：Vue 3 + Composition API
- 类型：**强制 TypeScript**（严格模式）。Vue 项目**一律用 TS**，禁止用纯 JS 写组件或逻辑
- 构建：Vite
- 状态管理：Pinia（开启持久化插件）
- 路由：Vue Router **history 模式**（`createWebHistory`），使用导航守卫检查登录状态；部署到不支持 URL rewrite 的静态托管时才退回 hash 模式
- UI 库：Element Plus、Ant Design Vue、Vuetify 按场景选用，亦会搭配 Tailwind CSS 快速原型
- 数据请求：axios 封装（统一拦截、错误处理、token 注入）
- **无感刷新 Token**：凡涉及登录鉴权的前端，axios **必须**实现无感刷新 -- 响应拦截器捕获 401 时，用 refresh token 静默换取新 access token 后自动重放原请求；并发请求需用队列/单飞（single-flight）避免重复刷新，刷新失败才跳转登录页。**例外**：若当前已在登录页，401 不触发刷新（登录接口本身返回 401 是凭证错误，直接向上抛出交由页面处理）
- 常用组合函数：`useAuth`、`useRequest`、`usePermission` 等

## 代码风格
- 单文件组件顺序：`<template>` → `<script setup lang="ts">` → `<style scoped>`
- **文件头注释块**：SFC 只在**文件最开头**（`<template>` 上方）用一个 HTML 注释块 `<!-- ... -->` 写一次（含作用描述、创建日期、修改日期，见 [SKILL.md](../SKILL.md) 注释规范）。**禁止**在 `<script setup>` 内重复书写，避免一份文件头出现两处。文件头模板：
  ```html
  <!--
    用户登录页 -- 用户名密码输入、前端校验与提交
    创建日期：2026-07-29
    修改日期：2026-08-01
  -->
  <template>
  	...
  </template>
  ```
- 格式化：Prettier + ESLint（eslint-plugin-vue）；Prettier 设 `useTabs: true` 以符合全局 Tab 约定
- **命名**：组件文件夹/组件名 `PascalCase`（如 `LoginForm`）；组合式函数（composables）文件与函数名一律 `useXxx` 前缀（如 `useAuth`、`useRequest`），放在 `src/composables/`（全局复用）或页面目录下（页面私有，与私有组件同级）
- **导入路径用别名 `@/`**：一律用 `@/xxx/xxx`（`@` 指向 `src`），**禁止**用 `../../xxx` 这类多级相对路径。在 `vite.config.ts` 的 `resolve.alias` 与 `tsconfig.json` 的 `paths` 中配置 `@` → `src`

### `<script setup>` 内部顺序
编写、修改或整理 Vue 代码时，先读 [code-organization.md](code-organization.md)。在不改变初始化顺序、副作用和组件行为的前提下，按照以下顺序排列：

1. 静态 import
2. type 和 interface
3. 常量、配置、正则、Set 和 Map
4. defineOptions、defineProps、defineEmits 和 defineExpose
5. composable 返回值、ref 和 reactive 状态
6. computed 派生状态
7. 自定义 directive 等属性定义
8. onMounted、onUnmounted 等生命周期注册
9. 初始化相关方法
10. 按页面展示顺序和业务流程排列的方法
11. submit、save、launch 等最终操作

静态 import 必须位于脚本顶部；动态 `import()` 按运行条件保留在对应函数或分支中。不要为了集中定义而移动存在初始化依赖、顶层副作用或注册顺序要求的语句。

业务流程为步骤 1、步骤 2、提交时，相关方法也优先按照步骤 1、步骤 2、提交排列。页面顺序无法明确判断或调整可能改变行为时保留现状。

## 目录结构
- **页面目录用 `views`，禁止用 `pages`**
- **一切皆 `index`**：每个页面/组件独立一个文件夹，入口文件统一命名 `index.vue`（`index.ts`、`index.css` 同理），即 `xxx/xxxx/index.xx` 结构
- **页面私有组件就近放置**：只在某个页面用到、非全局的组件，放在该页面目录下的 `components/`；全局复用组件才放到顶层 `src/components/`
- 示例（以 Login 为例）：
  ```
  src/
  ├── views/
  │   └── Login/
  │       ├── index.vue                  # 页面入口
  │       └── components/
  │           ├── LoginForm/index.vue    # 该页面私有组件
  │           └── QrCode/index.vue
  ├── components/                        # 全局复用组件（同样 xxx/index.vue）
  ├── types/                             # 前后端数据传输类型（见下）
  └── style/
      └── index.css                      # 全局样式
  ```

## 类型（types）
- **所有前后端数据传输的类型**（请求体、响应体等）统一放在 `src/types/` 下，按业务域分文件，命名 `xxx.d.ts`
- 命名约定：请求 `XxxReqVO`、响应 `XxxRespVO`。示例：登录接口的 `LoginReqVO` / `LoginRespVO` 放在 `src/types/auth.d.ts`（数据传输命名总规约见 [SKILL.md](../SKILL.md)）

## 开发体验（dev）
- **Prettier 配置**：新项目直接复制脚手架的 [project-template/.prettierrc.json](./project-template/.prettierrc.json)（`useTabs` 落地 Tab 缩进、`trailingComma: "all"` 落地"键值独占一行带尾逗号"；JSON/YAML 覆写为 2 空格与 `.editorconfig` 对齐）
- **启动自动打开浏览器**：dev 脚本加 `--open`，即 `package.json` 中 `"dev": "vite --open"`（或在 `vite.config` 设 `server: { open: true }`）
- **codeInspectorPlugin**：dev 环境接入 [`code-inspector-plugin`](https://github.com/zh-lx/code-inspector)，点击页面元素直接跳到编辑器对应源码。在 `vite.config.ts` 注册（仅开发生效）：
  ```ts
  import { codeInspectorPlugin } from 'code-inspector-plugin'

  export default defineConfig({
  	plugins: [
  		vue(),
  		codeInspectorPlugin({ bundler: 'vite' }), // 插件内部自动仅在 dev 生效
  	],
  })
  ```

## 环境变量
- 默认创建三份（Vite 命名规范，点号分隔）：
  - `.env`：所有环境共享的默认值
  - `.env.development`：开发环境（`vite`、`vite dev` 时加载）
  - `.env.test`：测试环境（通过 `--mode test` 加载）
  - `.env.production`：生产环境（`vite build` 时加载）
- 自定义变量必须以 `VITE_` 前缀命名才会暴露给客户端（如 `VITE_API_BASE_URL`）
- 含密钥的本地覆盖文件用 `.env.local` / `.env.*.local`，并加入 `.gitignore`

## 样式
- **全局样式**统一放 `src/style/index.css`，在入口处一次性引入
- **组件/页面私有样式**写在对应 SFC 的 `<style scoped>` 里，不放全局
- 优先 Tailwind CSS，`<style scoped>` 仅作补充

## 测试
- 单元测试：Vitest + Vue Test Utils（关键路径与公共组件必测）
- E2E 测试：Playwright
