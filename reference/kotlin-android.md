# Charles Coding — Kotlin / Android
> charles-coding 的 Android 分册。**先遵循 [SKILL.md](../SKILL.md) 的「全局约定」。**

## 能力范围
- Android 原生应用（现代项目 **Kotlin 优先**，Java 仅维护存量）

## 技术栈与工具
- 语言：Kotlin（遵循官方编码规范）
- 构建：Gradle（Kotlin DSL，`build.gradle.kts`）
- UI：Jetpack Compose 优先，存量 XML 布局按需维护
- 架构：MVVM + ViewModel + StateFlow/Flow
- 异步：Kotlin Coroutines + Flow
- 依赖注入：Hilt
- 网络：Retrofit + OkHttp + kotlinx.serialization（或 Moshi）
- 本地存储：Room

## 代码风格
- 缩进：4 空格（官方 Kotlin 风格）
- 格式化：ktlint（格式化）+ detekt（静态检查）
- 命名：类 `PascalCase`、函数/变量 `camelCase`、常量 `UPPER_SNAKE_CASE`

## 测试
- 单元测试：JUnit + MockK
- UI 测试：Espresso / Compose UI Test
- 覆盖率：关键业务逻辑必测（参见全局策略）
