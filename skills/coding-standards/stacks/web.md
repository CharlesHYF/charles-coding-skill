# Charles Coding -- Web 前端
> charles-coding 的浏览器端工程分册。**先遵循 [SKILL.md](../SKILL.md) 的交付红线与 `rules/` 通用规则**。语言规范见 [javascript-typescript.md](../languages/javascript-typescript.md) 与 [html-css.md](../languages/html-css.md)，框架规范见 [vue.md](vue.md) / [react.md](react.md)。

## 能力范围
- 运行在浏览器里的页面与单页应用，含管理后台、营销页与嵌入式页面

## 技术栈与工具
- 构建：Vite
- 包管理：pnpm，锁文件必须提交
- 格式化与检查：Prettier + ESLint + Stylelint

## 目录结构
`types` / `store` / `constants` 一律 index 化，入口只做再导出，实体放 `modules/`；测试代码不进 `src`。

```
frontend/
	src/
		main.ts         应用入口，全局组件在这里注册
		permission.ts   路由守卫与权限控制
		pages/          页面级组件，与路由一一对应
		components/     全局复用组件，全部在 main.ts 注册
		composables/    可复用逻辑（React 项目为 hooks/）
		api/            接口请求封装，按业务域分文件
		types/          index.ts 再导出，实体放 modules/
		store/          index.ts 再导出，实体放 modules/
		constants/      index.ts 再导出，实体放 modules/
		assets/         静态资源
		styles/         全局样式与 CSS 变量定义
	tests/            测试代码，不放进 src
```

## 兼容性基线
- 目标浏览器写进 `.browserslistrc` 或 `package.json` 的 `browserslist`，**不依赖工具默认值**
- 默认基线：最近两个版本的 Chrome / Edge / Firefox / Safari，不支持 IE
- 用到基线之外的 API 必须有降级路径或 polyfill，不允许直接崩在旧浏览器上

## 接口请求
- 请求封装集中在 `api/`，页面与组件**不直接调用 `fetch` 或 `axios`**
- 统一处理：基础地址、超时、鉴权头、错误码转换、重试策略
- 请求与响应类型显式声明，按 [naming.md](../rules/naming.md) 的数据传输命名规则取名
- **接口地址禁止硬编码**，走环境变量注入

## 性能
- 路由级代码分割，首屏包体积超过 300KB（gzip 后）必须拆分
- 图片资源用现代格式并声明宽高，避免布局抖动
- 列表渲染必须有稳定的 key，长列表用虚拟滚动
- 不在渲染路径里做同步的重计算，结果缓存或移到 Worker

## 可访问性
- 交互元素必须可键盘操作，自定义控件补 `role` 与 `aria-*`
- 焦点状态不允许用 `outline: none` 直接去掉，要么保留要么替换成同等可见的样式
- 文本与背景对比度不低于 4.5:1
- 表单错误提示与对应控件建立关联，不只靠颜色传达状态

## 安全
- **禁止用字符串拼接写入 DOM**：不用 `innerHTML` 拼接用户输入，框架提供的插值默认转义，需要渲染富文本时先做白名单过滤
- 禁止把密钥、token 写进前端代码或环境变量注入到打包产物里
- 外部链接加 `rel="noopener noreferrer"`
- 生产构建关闭 sourcemap 或限制为仅上传到错误监控平台

## 测试
- 组件单元测试覆盖交互分支与边界状态（空、加载中、错误）
- 关键业务流程补端到端测试
- 覆盖率要求见 [testing.md](../domains/testing.md)
