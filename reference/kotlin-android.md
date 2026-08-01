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
- **空安全**：优先用可空类型 `?` 配合安全调用 `?.` / `?:` 兜底默认值；**禁止滥用 `!!`**（非空断言，一旦为 null 直接崩溃），仅在有充分上下文证明不可能为 null 时使用（并加注释说明理由）；跨层传递的可空字段用 `?.let { ... }` 处理，不做嵌套 `if (x != null)` 判空
- **协程**：ViewModel 内启动协程一律用 `viewModelScope.launch { ... }`（随 ViewModel 生命周期自动取消），禁止用 `GlobalScope.launch`；多个子协程需要「一个失败全部取消」时用结构化并发（`coroutineScope { launch { } ; launch { } }`），避免裸起互不关联的协程导致异常无法传播
- **DTO 用 `data class`**：网络请求/响应体、数据库实体传输对象一律用 `data class` 定义（自动生成 `equals`/`hashCode`/`copy`），字段用 `val` 不可变

## 分层示例（Compose + ViewModel）
```kotlin
// UI 层：只做展示与用户交互转发，不写业务逻辑
@Composable
fun UserProfileScreen(viewModel: UserProfileViewModel = hiltViewModel()) {
	val uiState by viewModel.uiState.collectAsStateWithLifecycle()
	when (uiState) {
		is UiState.Loading -> LoadingIndicator()
		is UiState.Success -> UserProfileContent(uiState.data)
		is UiState.Error -> ErrorMessage(uiState.message)
	}
}

// ViewModel 层：持有 UI 状态，调用 Repository/UseCase，不持有 Context/View 引用
@HiltViewModel
class UserProfileViewModel @Inject constructor(
	private val userRepository: UserRepository,
) : ViewModel() {
	private val _uiState = MutableStateFlow<UiState>(UiState.Loading)
	val uiState: StateFlow<UiState> = _uiState.asStateFlow()

	fun loadProfile(userId: String) {
		viewModelScope.launch {
			runCatching { userRepository.getProfile(userId) }
				.onSuccess { _uiState.value = UiState.Success(it) }
				.onFailure { _uiState.value = UiState.Error(it.message ?: "加载失败") }
		}
	}
}
```

## 文件头模板
```kotlin
/**
 * 文件作用：用户信息 ViewModel——管理用户详情页的 UI 状态与数据加载。
 * 创建日期：2026-07-29
 * 修改日期：2026-08-01
 */
```

## 测试
- 单元测试：JUnit + MockK
- UI 测试：Espresso / Compose UI Test
- 覆盖率：关键业务逻辑必测（参见全局策略）
