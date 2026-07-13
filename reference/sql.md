# Charles Coding — SQL
> charles-coding 的 SQL 分册。**先遵循 [SKILL.md](../SKILL.md) 的「全局约定」。**

## 数据库设计规范（阿里巴巴开发手册）
> 核心原则：**必须**遵守阿里巴巴 Java 开发手册（泰山版）中的数据库设计规约。
> 以下列出 AI 最容易违反的高频规则，完整规约请参考原手册。

### 命名
- **表名/字段名**：小写 + 下划线，见名知义，**禁止**数字开头或拼音
- **索引命名**：主键 `pk_字段名`、唯一 `uk_表名_字段名`、普通 `ix_表名_字段名`（与下方索引策略对齐）
- **长度上限**：表名、字段名 ≤ 32 个字符

### 字段类型（高频排雷 ⚠️）
- **禁止 `ENUM`**：用 `TINYINT` 或 `VARCHAR` 代替。枚举值变化时 `ALTER TABLE` 有兼容性隐患，且 MySQL 行为不可预测
- **禁止 `TEXT` / `BLOB`**：除非单字段确实超过 65535 字符且很少被查询。大文本应拆表或使用独立存储
- **金额字段**：**强制** `DECIMAL(m, n)`，**禁止** `FLOAT` / `DOUBLE`（精度丢失）
- **布尔字段**：`TINYINT(1)`，**禁止** `BIT`（跨 ORM 兼容性差）
- **自增 ID**：`BIGINT UNSIGNED AUTO_INCREMENT`（不分表场景）；分表场景用分布式 ID，字段类型 `VARCHAR(32)`
- **VARCHAR 长度不要拍脑袋定 255**：按实际业务需求设置合适长度（如手机号 20、姓名 50、URL 512）

### 约束
- **所有字段**必须 `NOT NULL`，并设置有意义的 `DEFAULT` 值（极少例外需注释说明）
- **必须有主键**，禁止无主键表
- **禁止外键**在数据库层使用（由应用层保证数据一致性）
- **字符集**：统一 `UTF8MB4`

### 注释
- **所有表和所有字段**必须添加 `COMMENT`，说明字段的业务含义
- 状态字段注释必须列明所有枚举值含义（如 `COMMENT '状态: 0-禁用, 1-启用, 2-删除'`）

### 查询
- **三表 JOIN 上限**：一条 SQL 多表关联不得超过 3 张表
- **禁止** `SELECT *`，必须列名
- 单表行数超过 **500 万**或单表列数超过 **50** 时，必须考虑分库分表

## 数据库支持
- PostgreSQL、MySQL、SQLite 均可，视项目需求选择

## 编写风格
- **简单 CRUD**：优先使用 MyBatis Plus 内置方法（BaseMapper、ServiceImpl 等），不手写
- **复杂查询/优化**：手写 SQL（Mapper XML 或注解），按需使用 Explain 分析执行计划
- **关键字全部大写**，缩进 **2 空格**（⚠️ **全局 Tab 的例外**），每个子句独立一行
- 示例：
  ```sql
  SELECT u.id, u.name, o.amount
  FROM users u
  JOIN orders o ON u.id = o.user_id
  WHERE u.status = 'active'
  ORDER BY o.created_at DESC;
  ```

## 索引策略
- 命名：`ix_tablename_column`
- 原则：为 `WHERE`、`JOIN`、`ORDER BY` 中频繁出现的列建立索引
- 覆盖索引：在组合查询中优先创建覆盖索引

## 安全
- 100% 参数化查询，杜绝字符串拼接
- 使用 MyBatis 的 `#{}` 占位符，避免 `${}` 直接拼接用户输入
