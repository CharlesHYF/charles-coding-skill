# Charles Coding -- HTML / CSS
> charles-coding 的 HTML / CSS 分册。**先遵循 [SKILL.md](../SKILL.md) 的交付红线与 `rules/` 通用规则**。浏览器端工程化规范见 [web.md](../stacks/web.md)。

## 能力范围
- 页面结构与样式，含 Vue SFC 的 `template` / `style` 块与 React 的 JSX 结构

## 技术栈与工具
- 缩进：Tab（HTML / CSS / SCSS）
- 格式化：Prettier；样式检查：Stylelint
- 预处理器：SCSS，不引入多套预处理器

## HTML
- **每个元素独占一行**，禁止把多个标签挤在同一行（如 `<li>a</li><li>b</li>`）；单个标签的多个属性可保留在同一行
- **语义化标签优先**：用 `header` / `nav` / `main` / `section` / `article` / `footer` 表达结构，**禁止整页用 `div` 堆砌**
- `html` 标签必须有 `lang` 属性；`img` 必须有 `alt`（装饰性图片写 `alt=""`）
- 表单控件必须有关联的 `label`，不能只靠 `placeholder` 说明用途
- 属性顺序固定：`id` -> `class` -> `name` -> `data-*` -> 其余属性 -> 事件绑定
- **禁止内联样式**：`style="..."` 只允许出现在由脚本动态计算的场景，静态样式一律进样式表

## CSS
- **每条声明独占一行**；选择器分组时每个选择器一行，逗号后换行；`{` 跟在选择器后不另起行；每个规则块之间空一行
  ```css
  .hero,
  .scenario-wrap {
  	grid-template-columns: 1fr;
  }
  ```
- class 命名统一 `kebab-case`，语义化取名（`.order-list` 而非 `.ol1`），**禁止**按视觉效果取名（`.red-text`、`.mt-20`，工具类框架除外）
- **禁止 `!important`**：出现即说明选择器权重设计有问题，改用更精确的选择器或调整层叠顺序；第三方样式覆盖等确需场景在同行注释写明原因
- **禁止 ID 选择器做样式**：`#header { }` 权重过高难以覆盖，样式一律用 class
- 选择器嵌套不超过三层，超过说明结构需要调整
- 颜色、间距、字号、圆角、阴影等**一律定义为 CSS 自定义属性**放在 `:root`，禁止散落的十六进制色值与魔法数值
- 单位：字号与间距用 `rem`，边框与细节用 `px`，禁止混用无规律
- 媒体查询断点定义为变量集中管理，不在各处手写数值

## 文件头模板
```css
/*
 * 定义后台品牌管理页面的布局与视觉样式
 * 创建日期：2026-07-15
 * 修改日期：2026-09-14
 */
```

HTML 与 Vue SFC 放文件最顶部：
```html
<!--
管理当前会话的消息与对话操作
创建日期：2026-07-15
修改日期：2026-09-14
-->
```

## 参考范例
完整可对照的范例文件见 [`templates/examples/example.html`](../../../templates/examples/example.html)。
