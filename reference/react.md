# Charles Coding — React
> charles-coding 的 React 分册。**先遵循 [SKILL.md](../SKILL.md) 的「全局约定」。**

## 能力范围
- 单页应用、SSR/SSG 全栈应用、高交互性后台

## 技术栈（最优组合）
- 框架：Next.js 14+ (App Router)，SSR 优先
- 类型：TypeScript 严格模式
- 状态管理：Zustand（轻量全局态），React Context 仅用于主题/鉴权等少数场景
- 数据请求：TanStack Query (React Query) + axios
- **无感刷新 Token**：凡涉及登录鉴权的前端，axios **必须**实现无感刷新——响应拦截器捕获 401 时，用 refresh token 静默换取新 access token 后自动重放原请求；并发请求需用队列/单飞（single-flight）避免重复刷新，刷新失败才跳转登录页。**例外**：若当前已在登录页，401 不触发刷新（登录接口本身返回 401 是凭证错误，直接向上抛出交由页面处理）
- 表单：React Hook Form + Zod 校验
- UI 方案：Tailwind CSS + shadcn/ui，构建可复用组件库
- 路由：Next.js 文件系统路由，动态路由采用 `[slug]` 形式

## 代码风格
- 类型：**强制 TypeScript**（严格模式），禁止用纯 JS 写组件或逻辑
- 组件：函数式组件 + Hooks
- 客户端组件：仅在必要时添加 `'use client'`，数据获取优先在服务端组件中进行
- 格式化：Prettier + ESLint（或 Biome 一把梭）；用 Prettier 时设 `useTabs: true`，用 Biome 时设 `indentStyle: tab`
- **导入路径用别名 `@/`**：一律用 `@/xxx/xxx`（`@` 指向 `src`），**禁止**用 `../../xxx` 这类多级相对路径。在 `tsconfig.json` 的 `paths` 配置 `@/*` → `src/*`（Next.js 默认已内置该别名）
- **文件头注释块**：每个 `.tsx` / `.ts` 文件最开头用块注释写一次文件作用与日期（见 [SKILL.md](../SKILL.md) 注释规范），模板：
  ```tsx
  /**
   * 登录表单组件
   *
   * 创建日期：2026-07-29
   * 修改日期：2026-07-29
   */
  'use client'

  export default function LoginForm() {
  	...
  }
  ```
- **命名**：组件文件夹/组件名 `PascalCase`（如 `LoginForm`）；自定义 Hook 文件与函数名一律 `useXxx` 前缀（如 `useAuth`、`useDebounce`），全局复用放 `src/hooks/`，页面私有放该路由 `_components/` 同级

## 目录结构
- **路由页面**：Next.js App Router 强制以 `app/` 为路由目录，路由入口文件为框架约定的 `page.tsx` / `layout.tsx`（此处不改名为 `index`，遵循框架要求）
- **一切皆 `index`（非路由文件）**：每个组件独立一个文件夹，入口文件统一命名 `index.tsx`（`index.ts`、`index.css` 同理），即 `xxx/xxxx/index.tsx` 结构
- **页面私有组件就近放置**：只在某个路由页面用到、非全局的组件，放在该路由目录下的 `components/`（App Router 中前缀下划线 `_components/` 可避免被识别为路由段）；全局复用组件放到顶层 `src/components/`
- 示例（以 Login 为例）：
  ```
  src/
  ├── app/
  │   └── login/
  │       ├── page.tsx                   # 路由入口（框架约定）
  │       └── _components/
  │           ├── LoginForm/index.tsx    # 该页面私有组件
  │           └── QrCode/index.tsx
  ├── components/                        # 全局复用组件（xxx/index.tsx）
  ├── types/                             # 前后端数据传输类型（见下）
  └── style/
      └── index.css                      # 全局样式
  ```

## 类型（types）
- **所有前后端数据传输的类型**（请求体、响应体等）统一放在 `src/types/` 下，按业务域分文件，命名 `xxx.d.ts`
- 命名约定：请求 `XxxReqVO`、响应 `XxxRespVO`。示例：登录接口的 `LoginReqVO` / `LoginRespVO` 放在 `src/types/auth.d.ts`（数据传输命名总规约见 [SKILL.md](../SKILL.md)）

## 开发体验（dev）
- **启动自动打开浏览器**：Next.js 15+ 的 `next dev` 支持 `--open`（`"dev": "next dev --open"`）；旧版本无该 flag，可用 `concurrently` 等在 dev 脚本里并行执行 `open`/`opener` 打开地址
- **codeInspectorPlugin**：dev 环境接入 [`code-inspector-plugin`](https://github.com/zh-lx/code-inspector)，点击页面元素直接跳到编辑器对应源码。在 `next.config` 的 webpack 钩子注册（仅开发生效）：
  ```ts
  import { codeInspectorPlugin } from 'code-inspector-plugin'

  const nextConfig = {
  	webpack: (config, { dev, isServer }) => {
  		config.plugins.push(codeInspectorPlugin({ bundler: 'webpack', dev, isServer }))
  		return config
  	},
  }
  export default nextConfig
  ```
  > 使用 Turbopack（`next dev --turbopack`）时按插件文档改用其 Turbopack 接入方式。

## 环境变量
- 默认创建三份（Next.js 命名规范，点号分隔）：
  - `.env`：所有环境共享的默认值
  - `.env.development`：开发环境（`next dev` 时加载）
  - `.env.test`：测试环境（测试运行 / `NODE_ENV=test` 时加载）
  - `.env.production`：生产环境（`next build` / `next start` 时加载）
- 需暴露给浏览器的变量必须以 `NEXT_PUBLIC_` 前缀命名（如 `NEXT_PUBLIC_API_BASE_URL`），无前缀者仅服务端可读
- 含密钥的本地覆盖文件用 `.env.local` / `.env.*.local`，并加入 `.gitignore`

## 样式
- **全局样式**统一放 `src/style/index.css`，在根 `layout.tsx` 一次性引入
- **组件/页面私有样式**就近放在对应组件目录（如 CSS Module `index.module.css`），不放全局
- 优先 Tailwind CSS，复杂样式抽取为自定义组件

## 测试
- 单元 / 组件测试：Vitest + @testing-library/react
- E2E 测试：Playwright
- 默认要求关键路径和公共组件有测试覆盖
