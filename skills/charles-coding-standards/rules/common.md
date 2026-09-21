# Charles Coding -- 通用规范
> 缩进、行尾、禁用符号、代码块边界、展开换行与常量。**所有语言通用，含前端**（JS / TS / Vue / React / HTML / CSS）。

## 编辑与格式
## 工具强制类（由 Prettier/gofmt/Ruff + editorconfig 自动保证，不靠自觉）
| 项目       | 规范                                                              |
| ---------- | ----------------------------------------------------------------- |
| 缩进       | 默认 Tab；Python / Kotlin 4 空格、SQL / YAML / JSON 2 空格（见 `.editorconfig`） |
| 行尾       | 统一 LF，由 `.gitattributes` 强制（不再"跟随 OS 默认"）           |
| 编码       | UTF-8                                                             |
| import 排序 | 由各语言格式化工具（Prettier/gofmt/Ruff 等）自动整理             |
| 代码格式化 | 强制使用各语言对应的格式化工具（见各分册）自动执行                |

## 禁用符号（scripts/check.sh 拦截，非纯手动）
> 以下由脚手架 `scripts/check.sh` 扫描拦截（`make lint` 与 CI 均会 fail），不是纯手动自查。规则句一律用**码点**指代被禁字符，故本文件自身不含被禁字符。

| 类别   | 规范                                                                                     |
| ------ | ---------------------------------------------------------------------------------------- |
| 引号   | 严禁 Unicode 弯引号（U+2018/2019/201C/201D）、CJK 角引号（U+300C-300F）、全角引号（U+FF02/FF07）；统一用 ASCII 直引号 `"` / `'` 或不加引号。书名号《》(U+300A/300B) 是正常中文标点，不禁。 |
| 破折号 | 严禁 Unicode 破折号/横线，含 em dash、en dash 等（U+2010-2015、U+2212、U+FF0D、U+2E3A/2E3B）；统一用半角双连字符 `--`（两个 U+002D）。目录树制表符（U+2500~257F）不禁。 |
| Emoji  | 严禁在代码、注释、文档、提交信息中出现 Emoji；确需图标用 SVG 或 icon 字体。 |

## 手动约定类（工具不保证，Agent 须手动遵守并自查）
| 项目             | 规范                                                              | lint 提示 |
| ---------------- | ----------------------------------------------------------------- | --------- |
| 注释语言         | 中文                                                              | 无法配置，纯手动 |
| 代码块间空行     | 见下方"代码块与大括号规范"                                       | 无法配置，纯手动 |
| 键值独占一行     | 见下方"代码展开与换行规范"                                       | ESLint `object-curly-newline` |
| 魔法数字         | 见下方"常量与魔法数字规范"                                       | `no-magic-numbers` |
| 命名见名知义     | 见下方"变量与函数命名规范"                                       | 无法配置，纯手动 |

## 代码块与大括号规范
- **强制使用大括号**：`if`、`else`、`for`、`while`、`function` 等所有控制流/函数体语句，**无论内部只有一行还是多行，都必须使用大括号 `{}`**，禁止省略
- **代码块与相邻同级语句之间留空行**：一个完整代码块（`if/else` 整体、`for`、`while`、`try/catch` 整体、函数）与其上下相邻的**同级语句**之间各留一个空行，让块的起止边界清晰可辨。判定边界：
  - **不要求空行**的位置：`} else {`、`} catch {`、`} finally {` 等续接行（它们属于同一个块）；块内第一行与 `{` 之间、最后一行与 `}` 之间；文件/函数的第一条与最后一条语句外侧
  - 连续多个块之间留一个空行即可，不叠加
- 示例（`if/else` 整体作为一个块，与前后语句之间各空一行）：
  ```java
  int total = calcTotal();

  if (total > MAX_LIMIT) {
      reject(total);
  } else {
      accept(total);
  }

  notifyUser();
  ```

## 元素与空行排版
> 优先级高于任何工具的默认风格。排版只改格式，**不改变顺序、命名、属性与业务逻辑**。

- **缩进用 Tab**，子级比父级深一级
- **同级之间空一行**：
  - 模板中同一父元素下的相邻子元素之间空一行
  - TS / JS 中同一数组的相邻元素之间空一行
  - 顶层 `export` 之间、函数之间空一行
- **同一对象内部的键值对之间不空行**；对象内部逻辑上分组时，组之间可空一行
- **所有元素写成多行形式**：属性各占一行，文本内容单独占一行，结束的 `>` 或 `/>` 单独占一行；即使标签很短、即使没有属性也一样
- **只有组件自闭合**：`div`、`section`、`iframe`、`button`、`pre`、`article`、`span` 等原生 HTML 标签即使没有子内容也写成开闭成对形式
- 换行不得丢掉 `as const`、类型断言、分号等语法要素

模板侧细则与完整示例见 [vue.md](../stacks/vue.md)，脚本侧见 [javascript-typescript.md](../languages/javascript-typescript.md)。


## 代码展开与换行规范（严禁并排）
- **对象/字典/结构体/映射字面量：每个键值独占一行**，并带行尾逗号，**严禁**多个键值并排在同一行：
  ```js
  const p = {
  	x: 12,
  	y: 13,
  };
  ```
- **HTML / JSX：每个元素独占一行**，**严禁**把多个标签挤在同一行（如 `<li>a</li><li>b</li>`）；单个标签的多个属性可保留在同一行
- **CSS：每条声明独占一行**；选择器分组时**每个选择器一行**（逗号后换行）；`{` 不另起行，跟在选择器后；**每个规则块之间空一行**。示例：
  ```css
  .hero,
  .scenario-wrap {
  	grid-template-columns: 1fr;
  }
  ```
- 完整可参考的范例文件：[`example.html`](../../../templates/examples/example.html)；测试用例范例见 [`templates/examples/test_cases/`](../../../templates/examples/test_cases/)；模块文档范例见 [`templates/examples/docs/modules/`](../../../templates/examples/docs/modules/)


## 常量与魔法数字规范
- **禁止魔法数字**：代码中**严禁**直接出现裸数字（如 `if (count > 100)`、`Thread.sleep(5000)`），所有有语义的数字必须定义为具名常量，置于文件/类顶部
- **常量命名**：全大写下划线 `MAX_RETRY_COUNT`、`DEFAULT_TIMEOUT_MS`，见名知义
- 示例：
  ```java
  private static final int MAX_RETRY_COUNT = 3;
  if (retryCount > MAX_RETRY_COUNT) {
      return;
  }
  ```

