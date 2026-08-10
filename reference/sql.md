# Charles Coding -- SQL
> charles-coding 的 SQL 分册。**先遵循 [SKILL.md](../SKILL.md) 的"全局约定"。**

## 数据库设计规范（阿里巴巴开发手册）
> 核心原则：**必须**遵守阿里巴巴 Java 开发手册（泰山版）中的数据库设计规约。
> 以下列出 AI 最容易违反的高频规则，完整规约请参考原手册。

### 命名
- **表名/字段名**：小写 + 下划线，见名知义，**禁止**数字开头或拼音
- **索引命名**：主键 `pk_字段名`、唯一 `uk_表名_字段名`、普通 `ix_表名_字段名`（与下方索引策略对齐）
- **长度上限**：表名、字段名 ≤ 32 个字符

### 字段类型（高频排雷）
- **禁止 `ENUM`**：用 `TINYINT`（MySQL）或 `SMALLINT`（PostgreSQL）/ `VARCHAR` 代替。枚举值变化时 `ALTER TABLE` 有兼容性隐患
- **禁止 `TEXT` / `BLOB`**：除非单字段确实超过 65535 字符且很少被查询。大文本应拆表或使用独立存储（PostgreSQL 对应 `TEXT` / `BYTEA`）
- **金额字段**：**强制** `DECIMAL(m, n)`，**禁止** `FLOAT` / `DOUBLE`（精度丢失）
- **布尔字段**：MySQL 用 `TINYINT(1)`（**禁止** `BIT`）；PostgreSQL 用 `BOOLEAN` 或 `SMALLINT`
- **主键 ID 严禁自增**：**禁止** `AUTO_INCREMENT`（MySQL）/ `SERIAL`（PostgreSQL），一律用**雪花 ID（Snowflake）** 等分布式 ID，字段类型 `BIGINT`（应用层生成后写入）。理由：避免暴露业务量、分库分表冲突、迁移合并困难
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
  -- ========================
  -- cv_order 订单主表（MySQL）
  -- ========================
  CREATE TABLE cv_order (
  	id          BIGINT          NOT NULL COMMENT '订单ID',
  	user_id     BIGINT          NOT NULL COMMENT '下单用户ID',
  	shop_id     BIGINT          NOT NULL COMMENT '所属店铺ID',
  	amount      DECIMAL(10,2)   NOT NULL DEFAULT 0.00 COMMENT '订单金额(元)',
  	status      TINYINT         NOT NULL DEFAULT 0 COMMENT '订单状态: 0-待支付, 1-已支付, 2-已完成',
  	create_time DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  	PRIMARY KEY (id)
  ) ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4
    COMMENT = '订单主表';
  ```

  ```sql
  -- ========================
  -- cv_order 订单主表（PostgreSQL）
  -- ========================
  CREATE TABLE cv_order (
  	id          BIGINT          NOT NULL,
  	user_id     BIGINT          NOT NULL,
  	shop_id     BIGINT          NOT NULL,
  	amount      DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
  	status      SMALLINT        NOT NULL DEFAULT 0,
  	create_time TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  	PRIMARY KEY (id)
  );

  COMMENT ON TABLE  cv_order           IS '订单主表';
  COMMENT ON COLUMN cv_order.id        IS '订单ID';
  COMMENT ON COLUMN cv_order.user_id   IS '下单用户ID';
  COMMENT ON COLUMN cv_order.shop_id   IS '所属店铺ID';
  COMMENT ON COLUMN cv_order.amount    IS '订单金额(元)';
  COMMENT ON COLUMN cv_order.status    IS '订单状态: 0-待支付, 1-已支付, 2-已完成';
  COMMENT ON COLUMN cv_order.create_time IS '创建时间';
  ```

### 查询
- **三表 JOIN 上限**：一条 SQL 多表关联不得超过 3 张表
- **禁止** `SELECT *`，必须列名
- 单表行数超过 **500 万**或单表列数超过 **50** 时，必须考虑分库分表

## 类型对照：MySQL ↔ PostgreSQL
> 本规范以 MySQL 为基准书写，以下为 PostgreSQL 等价类型，建表时直接替换。

| 含义 | MySQL | PostgreSQL |
|------|-------|------------|
| 小整数 / 布尔 | `TINYINT` | `SMALLINT`（或 `BOOLEAN`） |
| 整数 | `INT` | `INTEGER` |
| 长整数 | `BIGINT` | `BIGINT` |
| 定长字符串 | `VARCHAR(n)` | `VARCHAR(n)` |
| 文本（禁止） | `TEXT` / `BLOB` | `TEXT` / `BYTEA` |
| 定点小数 | `DECIMAL(m,n)` | `DECIMAL(m,n)` |
| 日期时间 | `DATETIME` | `TIMESTAMP`（或 `TIMESTAMPTZ`） |
| 默认当前时间 | `DEFAULT CURRENT_TIMESTAMP` | `DEFAULT CURRENT_TIMESTAMP` |
| 自动更新时间 | `ON UPDATE CURRENT_TIMESTAMP` | 需触发器（见下方示例） |
| 自增 ID（禁止） | `AUTO_INCREMENT` | `SERIAL` / `BIGSERIAL` |

## 数据库支持
- PostgreSQL、MySQL、SQLite 均可，视项目需求选择

## 编写风格
- **简单 CRUD**：优先使用 MyBatis Plus 内置方法（BaseMapper、ServiceImpl 等），不手写
- **复杂查询/优化**：手写 SQL（Mapper XML 或注解），按需使用 Explain 分析执行计划
- **关键字全部大写**，缩进 **2 空格**（**全局 Tab 的例外**），每个子句独立一行
- **文件头注释**：每个 `.sql` 文件顶部必须包含缩写文件头 + 数据库声明，MySQL / PostgreSQL 分别如下：
  ```sql
  -- AI 绘图平台数据库表结构
  -- Database: ai_drawing  (MySQL)
  SET NAMES utf8mb4;
  SET CHARACTER SET utf8mb4;
  USE ai_drawing;
  ```

  ```sql
  -- AI 绘图平台数据库表结构
  -- Database: ai_drawing  (PostgreSQL)
  -- 通过 psql 连接指定：psql -d ai_drawing -f this_file.sql
  -- 或在文件内执行（不推荐用于 migration 脚本）：
  -- \c ai_drawing
  ```
- **分区注释**：表按业务域分组，组间用双线分隔，组内表间空一行：
  ```sql
  -- ============================================================
  -- 公共基础
  -- ============================================================
  ```
- **表级注释**：每个 CREATE TABLE 上方用单线分隔 + 中文名：
  ```sql
  -- ========================
  -- res_upload_file 上传文件记录表
  -- ========================
  CREATE TABLE res_upload_file ( ...
  ```
- 完整建表示例：
  ```sql
  -- ========================
  -- sys_user 系统用户表（MySQL）
  -- ========================
  CREATE TABLE sys_user
  (
  	id          BIGINT       NOT NULL COMMENT '主键 ID',
  	username    VARCHAR(50)  NOT NULL COMMENT '用户名',
  	password    VARCHAR(100) NOT NULL COMMENT '密码',
  	status      TINYINT      NOT NULL DEFAULT 1 COMMENT '状态 1正常 0禁用',
  	create_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  	update_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  	deleted     TINYINT      NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  	PRIMARY KEY (id),
  	KEY idx_username (username)
  ) ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4
    COLLATE = utf8mb4_unicode_ci
    COMMENT = '系统用户表';
  ```

  ```sql
  -- ========================
  -- sys_user 系统用户表（PostgreSQL）
  -- ========================
  CREATE TABLE sys_user
  (
  	id          BIGINT       NOT NULL,
  	username    VARCHAR(50)  NOT NULL,
  	password    VARCHAR(100) NOT NULL,
  	status      SMALLINT     NOT NULL DEFAULT 1,
  	create_time TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  	update_time TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  	deleted     SMALLINT     NOT NULL DEFAULT 0,
  	PRIMARY KEY (id)
  );

  -- PostgreSQL 不支持 ON UPDATE，需用触发器自动更新 update_time
  CREATE OR REPLACE FUNCTION update_sys_user_time()
  RETURNS TRIGGER AS $$
  BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
  END;
  $$ LANGUAGE plpgsql;

  CREATE TRIGGER trg_sys_user_update
    BEFORE UPDATE ON sys_user
    FOR EACH ROW EXECUTE FUNCTION update_sys_user_time();

  COMMENT ON TABLE  sys_user            IS '系统用户表';
  COMMENT ON COLUMN sys_user.id         IS '主键 ID';
  COMMENT ON COLUMN sys_user.username   IS '用户名';
  COMMENT ON COLUMN sys_user.password   IS '密码';
  COMMENT ON COLUMN sys_user.status     IS '状态 1正常 0禁用';
  COMMENT ON COLUMN sys_user.create_time IS '创建时间';
  COMMENT ON COLUMN sys_user.update_time IS '更新时间';
  COMMENT ON COLUMN sys_user.deleted    IS '逻辑删除';

  CREATE INDEX ix_username ON sys_user (username);
  ```
- migration / 数据变动脚本文件头：
  ```sql
  -- 文件作用：将历史订单表中已完成订单迁移至归档表。
  -- 创建日期：2026-07-29
  -- 修改日期：2026-08-01
  INSERT INTO order_archive SELECT * FROM order_2024 WHERE status = 3;
  ```
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
- **MySQL**：`KEY ix_xxx (col)` 写在 CREATE TABLE 内部；**PostgreSQL**：`CREATE INDEX ix_xxx ON tablename (col)` 写在 CREATE TABLE 外部
- 原则：为 `WHERE`、`JOIN`、`ORDER BY` 中频繁出现的列建立索引
- 覆盖索引：在组合查询中优先创建覆盖索引

## 安全
- 100% 参数化查询，杜绝字符串拼接
- 使用 MyBatis 的 `#{}` 占位符，避免 `${}` 直接拼接用户输入
