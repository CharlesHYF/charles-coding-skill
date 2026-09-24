# Charles Coding -- Kotlin
> charles-coding 的 Kotlin 语言分册。**先遵循 [SKILL.md](../SKILL.md) 的交付红线与 `rules/` 通用规则**，本文件只列 Kotlin 专属规范。Android 平台规范见 [android.md](../stacks/android.md)。

## 能力范围
- Kotlin 编写的后端服务、Android 应用、命令行工具与脚本

## 技术栈与工具
- 语言：Kotlin（遵循官方编码规范）
- 构建：Gradle（Kotlin DSL，`build.gradle.kts`）
- 异步：Kotlin Coroutines + Flow
- 序列化：kotlinx.serialization（或 Moshi），同一项目只选一种
- 测试：JUnit + MockK

## 代码风格
- 缩进：4 空格（官方 Kotlin 风格，不用 Tab）
- 格式化：ktlint（格式化）+ detekt（静态检查），两者都接入 `make lint`
- 命名：类 `PascalCase`、函数与变量 `camelCase`、常量 `UPPER_SNAKE_CASE`、包名全小写
- **空安全**：优先用可空类型 `?` 配合安全调用 `?.` 与 `?:` 兜底默认值；**禁止滥用 `!!`**，仅在有充分上下文证明不可能为 null 时使用并加注释说明理由；跨层传递的可空字段用 `?.let { ... }` 处理，不做嵌套 `if (x != null)` 判空
- **协程作用域**：禁止使用 `GlobalScope.launch`；协程必须挂在有生命周期的作用域上。多个子协程需要"一个失败全部取消"时用 `coroutineScope { }` 结构化并发，避免裸起互不关联的协程导致异常无法传播
- **数据类**：网络请求响应体、数据库传输对象一律用 `data class` 定义，字段用 `val` 不可变
- **禁止在 data class 里写业务逻辑**：它只承载数据，计算与判断放 Service 层

## 集合处理写法
> 通用规则见 [common.md](../rules/common.md) 的"集合处理写法"。

- **禁止**集合操作函数 `map` / `filter` / `flatMap` / `mapNotNull` / `fold` / `reduce` / `groupBy` / `associate*` / `sumOf` / `forEach` 与 `asSequence()`，一律改为 `for` 循环
- **允许**：查找类单次调用 `any` / `all` / `first` / `find`，回调只写一个表达式；`sortedBy { it.createdAt }` 这类单独传入的排序 lambda
- **例外**：`Flow` / `StateFlow` 的 `map` / `filter` / `combine` 等操作符属于异步数据流，不是集合处理，照常使用
- **拦截方式**：`scripts/check.sh` 检查十三只拦 `forEach` / `forEachIndexed`、`asSequence()` 与 Java Stream；`map` / `filter` 等与 Flow 操作符同名，脚本分不清，属于手动约定，审查时逐处确认

错误：
```kotlin
val names = users.filter { it.active }.map { it.name }
```

正确：
```kotlin
val names = mutableListOf<String>()

for (user in users) {
    if (!user.active) {
        continue
    }

    names.add(user.name)
}
```

## 文件头模板
KDoc 放在**类型声明上方**（文件物理顶部是 `package` 与 `import`）；类上有注解时，注释块放在**注解之上**。
```kotlin
/**
 * 管理用户详情页的 UI 状态与数据加载
 * 创建日期：2026-07-29
 * 修改日期：2026-08-01
 */
@HiltViewModel
class UserViewModel : ViewModel() {
```

## 测试
- 单元测试：JUnit + MockK
- 协程测试用 `runTest`，不用 `Thread.sleep` 等待
- 覆盖率：关键业务逻辑必测，具体要求见 [testing.md](../domains/testing.md)
