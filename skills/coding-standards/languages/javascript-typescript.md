# Charles Coding -- JavaScript / TypeScript
> charles-coding 的 JS / TS 语言分册。**先遵循 [SKILL.md](../SKILL.md) 的交付红线与 `rules/` 通用规则**，本文件只列语言专属规范。框架规范见 [vue.md](../stacks/vue.md) / [react.md](../stacks/react.md)，服务端运行时见 [nodejs.md](../stacks/nodejs.md)。

## 能力范围
- 浏览器端脚本、Node 服务端代码、构建脚本、CLI 工具
- 新项目一律用 TypeScript，纯 JavaScript 仅用于维护存量代码和无构建步骤的小脚本

## 技术栈与工具
- 语言标准：ES2022 及以上，模块系统统一 ESM（`import` / `export`），不混用 CommonJS
- TypeScript：5.x
- 包管理：pnpm 优先，同一项目只用一种包管理器，锁文件必须提交
- 格式化：Prettier；Lint：ESLint（或 Biome，二选一，不并存）
- 测试：Vitest

## 代码风格
- 缩进：Tab
- 语句结尾**必须加分号**，不依赖自动分号插入
- 字符串统一双引号 `"`，需要插值时用模板字符串，禁止字符串拼接变量
- 声明一律 `const`，确需重新赋值才用 `let`，**禁止 `var`**
- 相等比较一律 `===` 与 `!==`，禁止 `==`
- **禁止链式可选调用掩盖错误**：`a?.b?.c?.d` 超过两层说明数据结构不明确，应先校验再取值
- 对象与数组字面量每个元素独占一行并带行尾逗号（见 [common.md](../rules/common.md)）

## TypeScript 专项
- **禁止 `any`**：确实无法确定类型时用 `unknown` 并在使用处收窄；第三方库缺类型时写局部 `.d.ts`，不用 `any` 糊过去
- `tsconfig.json` 基线必须开启：`strict`、`noImplicitAny`、`strictNullChecks`、`noUnusedLocals`、`noUnusedParameters`、`noFallthroughCasesInSwitch`
- **禁止 `@ts-ignore`**；确需跳过用 `@ts-expect-error` 并在同行注释写明原因，它在错误消失后会自己报错，不会长期残留
- 类型命名用 `PascalCase`，不加 `I` 前缀（用 `User` 不用 `IUser`）；泛型参数用有意义的名字（`TPayload`），单字母仅限 `T` 一个参数的简单场景
- 类型定义就近放在使用它的模块内；跨模块共享的类型集中放 `types/`，按 [naming.md](../rules/naming.md) 的数据传输命名规则取名
- 联合类型的判别字段统一叫 `type` 或 `kind`，全项目只选一个

## import 排版
> 顺序固定为：值 import -> type import -> 常量与其余代码。组间空一行，组内不空行。

分四组，依次排列：

1. **第三方值 import**（node_modules 里的包）
2. **项目内值 import**（`@/` 或相对路径）
3. **全部 type import**（先第三方，后项目内）
4. **常量、配置与其余代码**

```ts
import { ChevronDown, ChevronLeft, ChevronRight, Clock } from "lucide";
import { MorphIcon } from "morphicons/vue";

import { getDashboardOperations } from "@/api/admin/dashboard";
import EChart from "@/components/EChart/index.vue";

import type { EChartsOption } from "echarts";
import type {
	DashboardActivityVO,
	DashboardInboxItemVO,
	DashboardOperationsRespVO,
	DashboardProjectProgressVO,
} from "@/types";

const PERCENTAGE_MULTIPLIER = 100;
```

- **type 导入一律用 `import type`**，不与值导入混写在同一条语句里
- **具名导入超过三个，或整行超过 printWidth 时，每个导入独占一行**并带行尾逗号
- 组内按模块路径字母序排列
- 静态 import 必须在文件顶部；动态 `import()` 属于运行逻辑，保留在实际加载位置
- **禁止把 type import 混进值 import 组中间**，这是最常见的违规形态

## 数组与对象排版
- **数组字面量的相邻元素之间空一行**，元素内部的键值对不空行：
  ```ts
  export const RULE_STATUS_OPTIONS = [
  	{
  		label: "待确认",
  		tag: "pending-confirmation",
  		value: 1,
  	},

  	{
  		label: "已确认",
  		tag: "confirmed",
  		value: 2,
  	},
  ] as const;
  ```
- 对象内部逻辑上分组时，组之间可空一行；否则不空
- **顶层 `export` 之间空一行，函数之间空一行**
- 换行不得丢掉 `as const`、类型断言与分号


## 异步
- 统一 `async` / `await`，不混用 `.then()` 链
- **每个 `await` 的 Promise 都必须有错误处理路径**，要么在调用处 `try/catch`，要么由上层统一捕获，禁止裸 `await` 后不管失败
- 并发请求用 `Promise.all`；其中任一失败不应影响其余时用 `Promise.allSettled`，不要自己写计数器
- **禁止漏 `await`**：ESLint 开启 `no-floating-promises`

## 文件头模板
JSDoc 放在文件顶部（模块级），不放在第一个函数上方。
```ts
/**
 * 管理当前会话的消息与对话操作
 * 创建日期：2026-07-15
 * 修改日期：2026-09-14
 */
```

## 测试
- 框架 Vitest，测试文件与被测文件同名加 `.test.ts`
- 禁止用 `setTimeout` 等待异步结果，用测试框架提供的等待能力
- 覆盖率要求见 [testing.md](../domains/testing.md)
