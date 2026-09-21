# Charles Coding -- 命名规范
> 变量、函数、布尔、集合与数据传输对象的命名。所有语言通用。

## 数据传输命名规范
- **原则：每种语言遵循自己生态的主流命名，不强制统一后缀**。三类边界一致：请求 = 入参（前端 → 后端）、响应 = 出参（后端 → 前端展示）、DTO = 内部/跨服务流转（不直接暴露给前端）；后缀按各语言生态取用。
- **Java / Kotlin / TypeScript（前端 types/）**：请求 `XxxReqVO`、响应 `XxxRespVO`、内部 `XxxDTO`（`XxxReqDTO` / `XxxRespDTO`）。细分：新增/保存 `XxxSaveReqVO`、分页查询 `XxxPageReqVO`。示例：`LoginReqVO` / `LoginRespVO`
- **Go**：请求 `XxxRequest`、响应 `XxxResponse`，内部 `XxxDTO` 或直接传领域对象，放 `model/` 或 `dto/` 包
- **Python（FastAPI + Pydantic）**：用 Pydantic model，命名 `XxxCreate` / `XxxUpdate` / `XxxResponse` / `XxxFilter`，放 `schemas/` 或 `models/`

## 变量与函数命名规范
- **见名知义**：变量名、函数名必须能清晰表达其用途，**禁止**单字母变量（`i`/`j`/`k` 仅限循环索引）、缩写拼凑、无意义命名（`n`、`tmp`、`data`、`obj`、`item1` 等）
- **集合遍历**：循环变量要体现元素含义，用 `for (Item item : items)` 而非 `for (Item i : items)`；用 `for (User user : users)` 而非 `for (User u : users)`
- 示例：
  ```java
  // 正确：
  for (Order order : orders) { process(order); }
  String customerName = order.getCustomerName();

  // 禁止：
  for (Order o : orders) { process(o); }
  String n = order.getCustomerName();
  ```
- **函数名 = 动词 + 名词，动词与注释里的动作词一一对应**：获取 `get`、读取 `read`/`load`、查询 `query`/`find`、创建 `create`、更新 `update`、删除 `delete`、校验 `validate`、核验 `verify`、检查 `check`、过滤 `filter`、转换 `convert`/`transform`、组装 `build`、解析 `parse`、保存 `save`、限制 `limit`、截取 `truncate`、降级 `fallback`、跳过 `skip`、计算 `calculate`、汇总 `summarize`、对比 `compare`、收集 `collect`、记录 `record`
  - **同一动作全项目只用一个动词**：定了 `get` 就不要在别处写 `fetch` / `obtain` / `acquire`（把远程调用统一叫 `fetch` 也可以，但只能选一套）
  - **命名与注释的中文说法对齐**：`buildVerifyResult` 对应注释"组装核验结果"，不要代码叫 build、注释写"拼装"
- **禁止隐喻 / 口语命名**（与注释同一套要求）：`envelope`、`box`、`bag`、`stuff`、`thing`、`magic`、`doIt`、`doSomething`、`handleStuff` 一律不许；编号凑数名 `data1` / `item2` / `res3` 同样禁止。`scripts/check.sh` 检查四会拦截 `tmp` / `obj` / `foo` / `stuff` / `doIt` 这类占位名与编号名
- **布尔用 `is` / `has` / `can` / `should` 前缀**（`isEnabled`、`hasPermission`），集合用复数（`orders`、`userIds`）；禁止 `flag`、`status1` 这类含糊名
- **禁止拼音或拼音混拼**：`shangpinList`、`getYonghu`、`fapiaoNo` 一律改成英文业务词（`productList`、`getUser`、`invoiceNo`）
- **同一概念全项目同名**：同一个东西不要 A 处 `productId`、B 处 `goodsId`、C 处 `itemId`

