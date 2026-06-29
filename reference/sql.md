# Charles Coding — SQL

> charles-coding 的 SQL 分册。**先遵循 [SKILL.md](../SKILL.md) 的「全局约定」。**

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
