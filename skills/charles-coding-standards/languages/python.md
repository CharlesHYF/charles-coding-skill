# Charles Coding -- Python
> charles-coding 的 Python 分册。**先遵循 [SKILL.md](../SKILL.md) 的"全局约定"。**

## 能力范围
- Web 后端 (API)、脚本工具、数据处理、AI/ML 集成

## 技术栈与工具
- 版本：Python 3.10+
- 包管理与虚拟环境：首选 **uv**（替代传统 venv/pip），使用 `pyproject.toml` 管理依赖
- Web 框架：FastAPI（搭配 Pydantic v2）
- ORM：SQLAlchemy 2.0（异步优先）
- 数据库驱动：asyncpg（PostgreSQL）或 aiomysql（MySQL）
- 异步：全面使用 `async/await` 处理 IO 密集型任务
- 代码风格：PEP8 强制，使用 **Ruff** 替代 flake8 + isort + Black（缩进 4 空格，由 Ruff/editorconfig 统一）
- 类型注解：全部函数的参数与返回类型都要写注解（`self` / `cls` 除外），没有返回值写 `-> None`，`__init__`、嵌套函数与测试函数也不例外；`scripts/check.sh` 检查十四拦截缺失。注解写得对不对由 mypy 严格模式检查，mypy 未接入 `make verify`，需要时手动跑 `uv run mypy src`

## 文件头部模板
```python
# -*- coding: utf-8 -*-
"""
简要描述本文件职责，一到两句话，不带句号
创建日期：YYYY-MM-DD
修改日期：YYYY-MM-DD
"""
```

## 注释规范
- docstring：模块/类/公共函数必须写（定义体内第一个语句）；三段式 -- `"""` 独占首行、正文从第二行起顶格、`"""` 独占末行，单行内容同理，禁止把摘要和 `"""` 挤在一行。
- **docstring 统一用双引号 `"""`**，禁止单引号三引号（PEP 257）。注意：Ruff 的 D 系规则默认不开启，须在 `pyproject.toml` 显式 `extend-select = ["D300", "D213"]` 才会机器拦截（脚手架模板 [project-template/pyproject.toml](../templates/project-template/pyproject.toml) 已配好）；**禁止启用 D200 / D212** -- 两者要求摘要与引号收拢同行，与本规范三段式直接冲突。
- **单行说明一律用 `#`，禁止写成三引号字符串**：一句话的注释写 `# 说明`，不要写成三引号包一行字。那在 Python 里是一条 no-op 表达式语句，不是注释 -- 既不绑定对象、也不被 `help()` / IDE 识别，还会留在字节码里。
- 变量/常量/字段说明：用 `#` 写在其上一行，不写下方；禁止用悬空的 `"""..."""` 当变量文档（Python 里那是 no-op 字符串、不绑定变量、也不被工具识别为 docstring）。示例：
  ```python
  # 末阶段号:完成后无需确认门,整条分析即收尾。
  LAST_PHASE: Phase = Phase.LISTING
  ```

## 集合处理写法
> 通用规则见 [common.md](../rules/common.md) 的"集合处理写法"。`scripts/check.sh` 检查十三用语法树识别，不会误伤 ORM 的 `query.filter()` 这类方法调用。

- **禁止**：列表 / 字典 / 集合推导式、生成器表达式（含 `sum(x for x in ...)`、`any(...)`、`"".join(...)` 这类传参写法）、`map()` / `filter()` / `functools.reduce()`、海象运算符 `:=`、嵌套三元
- **允许**：单独作为参数的 lambda，如 `sorted(orders, key=lambda order: order.created_at)`
- **Ruff 里方向相反的规则禁止启用**：`C402` / `C403` / `C404` / `C417`（改写成推导式）、`PERF401` / `PERF403`（把循环改成推导式）、`SIM110`（把循环改成 `any()` / `all()`）、`FURB140`（改用 `itertools.starmap`）、`UP027`（改成生成器表达式）。脚手架 [pyproject.toml](../templates/project-template/pyproject.toml) 已把它们写进 `ignore`，以后按前缀整组开启 `C4` / `PERF` / `SIM` / `FURB` / `UP` 也不会生效

错误：遍历、类型检查、空值过滤、清洗和构造字典挤在一个表达式里，`strip()` 在条件和结果里各调一次
```python
return {
    asin.strip().upper(): site.strip().upper()
    for asin, site in sites.items()
    if isinstance(asin, str) and isinstance(site, str) and asin.strip() and site.strip()
}
```

正确：不合规的数据用 `continue` 提前跳过，清洗一次存进变量再判断
```python
result: dict[str, str] = {}

for asin, site in sites.items():
    if not isinstance(asin, str) or not isinstance(site, str):
        continue

    asin = asin.strip().upper()
    site = site.strip().upper()

    if not asin or not site:
        continue

    result[asin] = site

return result
```

## 测试
- 框架：pytest + pytest-asyncio
- 覆盖率：要求 >80%
- 测试数据工厂：factory_boy
- API 测试：httpx + pytest

## 项目结构
- 使用 `src/` 布局，核心代码置于 `src/package_name/`
- 配置通过 pydantic-settings 管理环境变量
- 目录布局示例：
  ```
  src/package_name/
  ├── api/                # FastAPI 路由（按业务域分文件）
  │   └── user.py
  ├── schemas/             # 请求/响应 DTO（Pydantic 模型），XxxCreate/XxxUpdate/XxxResponse/XxxFilter 落位于此
  │   └── user.py
  ├── service/             # 业务逻辑
  ├── models/              # SQLAlchemy ORM 实体
  ├── repository/          # 数据访问层
  └── core/                # 配置、依赖注入、公共工具
  ```
- **请求/响应 DTO 统一放 `schemas/`**：按业务域分文件（如 `schemas/user.py`）。Python（FastAPI + Pydantic）**不照搬** Java/Kotlin/TypeScript 的 `ReqVO`/`RespVO` 后缀，改用 Pydantic 生态惯用命名：创建用 `XxxCreate`、更新用 `XxxUpdate`、响应用 `XxxResponse`、查询过滤用 `XxxFilter`，语义上与 VO/DTO 对齐即可（与 [SKILL.md](../SKILL.md) 一致），例如：
  ```python
  # schemas/user.py
  class UserCreate(BaseModel):
      """
      创建用户请求
      """
      username: str
      email: str

  class UserUpdate(BaseModel):
      """
      更新用户请求
      """
      username: str | None = None
      email: str | None = None

  class UserResponse(BaseModel):
      """
      用户信息响应
      """
      id: int
      username: str

  class UserFilter(BaseModel):
      """
      用户查询过滤条件
      """
      username: str | None = None
  ```
