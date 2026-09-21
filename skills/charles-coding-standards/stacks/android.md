# Charles Coding -- Android
> charles-coding 的 Android 平台分册。**先遵循 [SKILL.md](../SKILL.md) 的交付红线与 `rules/` 通用规则**，语言层面的 Kotlin 规范见 [kotlin.md](../languages/kotlin.md)。

## 能力范围
- Android 原生应用（现代项目 Kotlin 优先，Java 仅维护存量）

## 技术栈与工具
- 构建：Gradle（Kotlin DSL，`build.gradle.kts`）
- UI：Jetpack Compose 优先，存量 XML 布局按需维护
- 架构：MVVM + ViewModel + StateFlow/Flow
- 依赖注入：Hilt
- 网络：Retrofit + OkHttp
- 本地存储：Room
- 测试：JUnit + MockK（单元）、Espresso / Compose UI Test（UI）

## 分层约束
- **UI 层（Composable）**：只做展示与用户交互转发，不写业务逻辑，不直接调用 Repository
- **ViewModel 层**：持有 UI 状态、调用 Repository 或 UseCase，**禁止持有 Context 或 View 引用**
- **Repository 层**：只做数据存取与来源切换（网络、本地），不写界面相关判断
- ViewModel 内启动协程一律用 `viewModelScope.launch { }`，随 ViewModel 生命周期自动取消

## 分层示例
```kotlin
/**
 * 展示用户资料并转发交互事件
 * 创建日期：2026-07-29
 * 修改日期：2026-08-01
 */
@Composable
fun UserProfileScreen(viewModel: UserProfileViewModel = hiltViewModel()) {
	val uiState by viewModel.uiState.collectAsStateWithLifecycle()

	when (uiState) {
		is UiState.Loading -> LoadingIndicator()
		is UiState.Success -> UserProfileContent(uiState.data)
		is UiState.Error -> ErrorMessage(uiState.message)
	}
}
```

```kotlin
/**
 * 管理用户详情页的 UI 状态与数据加载
 * 创建日期：2026-07-29
 * 修改日期：2026-08-01
 */
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

## 资源与配置
- 字符串一律进 `strings.xml`，**禁止在 Compose 或布局里硬编码中文文案**
- 尺寸进 `dimens.xml`，颜色进主题定义，禁止散落的魔法数值
- `minSdk` / `targetSdk` / `compileSdk` 在 `build.gradle.kts` 显式声明，不依赖默认值
- 签名配置、API 密钥不进仓库，走 `local.properties` 或 CI 密钥，`local.properties` 必须在 `.gitignore` 里

## 测试
- ViewModel 与 Repository 必测，UI 层至少覆盖关键路径
- UI 测试用 Compose UI Test 或 Espresso，不用真机截图比对作为唯一断言
