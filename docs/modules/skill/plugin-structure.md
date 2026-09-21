# Plugin 结构与场景工作流
> 模块职责：定义本仓的 plugin 目录结构、七个 skill 的边界与跨工具适配方式
> 负责人：Charles
> 系统模块：skill
> 关联文件：skills/charles-coding-standards/SKILL.md、.claude-plugin/plugin.json、tests/check_structure.sh

## 功能一：规范本体与场景工作流分离

### 功能描述
规范内容与使用场景拆成两层。`skills/charles-coding-standards/` 是规范本体，只放交付红线、场景路由与模块索引，细则下沉到 `rules/`、`languages/`、`stacks/`、`domains/` 四类分册。六个场景工作流各自是独立 skill，可以按 `<plugin>:<skill>` 直接调用，工作流只写步骤与闸门，需要规范细节时指向规范本体，不复制内容。

### 入参要求
- 使用者能判断当前属于哪个场景（新项目、老项目接入、新功能、Bug 修复、重构、审查）
- 判断不了时先读 `skills/charles-coding-standards/SKILL.md` 的场景路由表

### 参数
| 参数 | 类型 | 必填 | 说明 |
| ---- | ---- | ---- | ---- |
| 场景 | 枚举 | 是 | new-project / legacy-project / new-feature / bugfix / refactor / review |
| 变更类型 | 枚举 | 是 | 新功能 / 需求变更 / Bug 修复 / 重构 / 依赖升级，决定闸门要求 |
| 语言与技术栈 | 字符串 | 是 | 决定读哪几个 languages 与 stacks 分册 |

### 返回
- 该场景对应的执行步骤与交付闸门
- 需要额外阅读的规范模块清单

## 功能二：跨工具适配

### 功能描述
一份 `skills/` 内容配多个工具适配层，各工具按自己的清单格式加载同一批 skill，内容零重复。适配层包括 Claude Code、Cursor、Codex、Agents 与 Gemini 五套配置，版本号必须与规范本体一致。

### 入参要求
- 新增适配层时同步声明版本号，并加入 `tests/check_structure.sh` 的版本校验清单

### 参数
| 参数 | 类型 | 必填 | 说明 |
| ---- | ---- | ---- | ---- |
| 适配层目录 | 路径 | 是 | 各工具约定的配置目录 |
| 版本号 | 字符串 | 是 | 必须与 `skills/charles-coding-standards/SKILL.md` 的 metadata.version 一致 |

### 返回
- 各工具可加载的 plugin 配置
- 版本号不一致时由结构自检报错

## 功能三：结构自检

### 功能描述
`tests/check_structure.sh` 校验三件事：每个 skill 目录都有 SKILL.md 且声明的 name 与目录名一致、六处版本号一致、全部 Markdown 内部链接可达。重构或新增 skill 后必须跑通。

### 入参要求
- 在仓库根执行
- 新增占位型链接时同步更新脚本里的占位符白名单

### 参数
| 参数 | 类型 | 必填 | 说明 |
| ---- | ---- | ---- | ---- |
| 无 | -- | -- | 脚本自行扫描仓库 |

### 返回
- 逐项通过或失败的断言清单
- 存在失败项时退出码非 0
