# Charles Coding — Python
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
- 类型注解：全部函数添加类型注解，并使用 mypy 严格模式检查

## 文件头部模板
```python
# -*- coding: utf-8 -*-
"""
文件作用：简要描述本文件职责，一到两句话，句号结尾。
创建日期：YYYY-MM-DD
修改日期：YYYY-MM-DD
"""
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
      """创建用户请求"""
      username: str
      email: str

  class UserUpdate(BaseModel):
      """更新用户请求"""
      username: str | None = None
      email: str | None = None

  class UserResponse(BaseModel):
      """用户信息响应"""
      id: int
      username: str

  class UserFilter(BaseModel):
      """用户查询过滤条件"""
      username: str | None = None
  ```
