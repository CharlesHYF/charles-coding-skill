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
- **主键 ID 严禁自增**：**禁止** `AUTO_INCREMENT`，一律用**雪花 ID（Snowflake）** 等分布式 ID，字段类型 `BIGINT`（应用层生成后写入）。理由：避免暴露业务量、分库分表冲突、迁移合并困难
- **VARCHAR 长度不要拍脑袋定 255**：按实际业务需求设置合适长度（如手机号 20、姓名 50、URL 512）

### 约束
- **所有字段**必须 `NOT NULL`，并设置有意义的 `DEFAULT` 值（极少例外需注释说明）
- **必须有主键**，禁止无主键表
- **禁止外键**在数据库层使用（由应用层保证数据一致性）
- **字符集**：统一 `UTF8MB4`

### 注释（COMMENT 命名规范）
- **所有表和所有字段**必须添加 `COMMENT`，说明字段的**业务含义**
- **COMMENT 写业务语义，不写技术实现**：
  - 主键/外键 ID 的注释写**它代表的业务实体**，如 `用户ID`、`订单ID`、`所属店铺ID`，**严禁**写成 `雪花ID`、`主键`、`自增ID` 这类实现细节
  - 字段注释写它是什么、干什么用，不写它用什么类型/怎么存
- **状态/类型等枚举字段**：注释必须列明所有枚举值含义，如 `COMMENT '订单状态: 0-待支付, 1-已支付, 2-已发货, 3-已完成, 4-已取消'`
- **表注释**写这张表存什么业务数据，如 `COMMENT='订单主表'`
- 时间字段注释写业务含义，如 `创建时间`、`支付时间`、`最后修改时间`
- 示例：
  ```sql
  CREATE TABLE cv_order (
  	id          BIGINT       NOT NULL COMMENT '订单ID',
  	user_id     BIGINT       NOT NULL COMMENT '下单用户ID',
  	shop_id     BIGINT       NOT NULL COMMENT '所属店铺ID',
  	amount      DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '订单金额(元)',
  	status      TINYINT      NOT NULL DEFAULT 0 COMMENT '订单状态: 0-待支付, 1-已支付, 2-已完成',
  	create_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  	PRIMARY KEY (id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单主表';
  ```

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
