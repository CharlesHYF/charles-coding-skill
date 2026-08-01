# Charles Coding — 测试与压测
<!--
作用：调试与测试规范分册（含测试用例表格格式、强制要求、压测规范），从 SKILL.md 下沉迁移
创建日期：2026-07-29
-->
> charles-coding 调试与测试规范分册。先遵循 [SKILL.md](../SKILL.md)。

### 调试与测试
| 项目     | 规范                                                         |
| -------- | ------------------------------------------------------------ |
| 接口测试 | Postman                                                      |
| 调试方式 | 优先查看日志，万不得已才打断点                               |
| 覆盖率   | 后端核心逻辑 ≥80%；前端关键路径与公共组件必测；脚本/原型按需 |
| 用例文档 | 测试用例在 Markdown 中**用表格记录**，不用大段文字描述        |

#### 测试用例表格格式
- 编写/交付测试用例文档时，**必须用 Markdown 表格**呈现，禁止只用几句话笼统描述
- 表头固定包含以下列（按此顺序）：**测试编号、优先级、测试用例、前置条件、输入内容、预计结果、实际结果、是否通过、备注**
  - 核心必填：测试编号、测试用例、输入内容、预计结果、实际结果、是否通过
  - `是否通过` 填 Pass / Fail，是明确的达标判定；`优先级` 用 P0-P3 或 高/中/低；无前置条件填 `-`
- 示例：

  | 测试编号 | 优先级 | 测试用例 | 前置条件     | 输入内容            | 预计结果             | 实际结果 | 是否通过 | 备注 |
  | -------- | ------ | -------- | ------------ | ------------------- | -------------------- | -------- | -------- | ---- |
  | TC-001   | P0     | 正常登录 | 账号已注册   | 正确的账号密码      | 登录成功，返回 token | 待填写   | 待填写   | -    |
  | TC-002   | P1     | 密码错误 | 账号已注册   | 正确账号 + 错误密码 | 提示密码错误         | 待填写   | 待填写   | -    |

#### 测试用例强制要求
- **Agent 写完代码后必须提供测试用例**，放在项目根目录的 `test_cases/` 文件夹下，工整组织
- **按系统模块（backend / frontend / daemon）→ 测试类型（unit / smoke / blackbox / whitebox）两级目录组织**，如 `test_cases/backend/unit/login_test_cases.md`、`test_cases/frontend/smoke/smoke_test_cases.md`
- **必须实际运行并确保全部通过后再交付，禁止交付未验证的测试**
- **功能验证在开发（dev）、测试（test）两套环境完成**；**生产（prod）仅做只读冒烟与配置加载校验**（连通性、配置能否正确加载、`/health` 探活），**严禁在 prod 执行写操作或全量用例**
- **各类测试统一归入 `test_cases/`**：单元测试之外，**压力测试、冒烟测试、黑盒测试、白盒测试**的用例与脚本都放在 `test_cases/` 下，按系统模块与类型分子目录组织：
  - `test_cases/backend/unit/`：后端单元测试（按功能模块分文件：login、user、order、product 等）
  - `test_cases/backend/smoke/`：后端冒烟测试
  - `test_cases/backend/blackbox/`：后端黑盒测试
  - `test_cases/backend/whitebox/`：后端白盒测试
  - `test_cases/frontend/unit/`：前端单元测试（login、component 等）
  - `test_cases/frontend/smoke/`：前端冒烟测试
  - `test_cases/frontend/e2e/`：前端 E2E 测试
  - `test_cases/daemon/unit/`：守护进程单元测试
  - `test_cases/daemon/smoke/`：守护进程冒烟测试
  - `test_cases/stress/`：压力/性能测试（k6、JMeter、wrk 等脚本 + 结果）
  - 每个模块中**每个功能（func）都要写测试用例**，覆盖正向、异常、边界、并发的所有场景

#### 压测规范
- **默认工具用 k6**：脚本统一放 `test_cases/stress/`，JMeter、wrk 作为备选（团队已有存量脚本或特殊协议场景可用）
- **阈值必须写进脚本代码，由脚本自动判定 Pass/Fail**，不允许压测完只看数字凭感觉判断，k6 用 `thresholds` 配置断言
- **预留核心指标**：
  - QPS/RPS（每秒请求数）
  - P95/P99 延迟
  - 错误率（`http_req_failed` < 1%）
  - 并发 VU（虚拟用户数，阶梯加压：如 10 → 50 → 100 → 200）
  - TPS（每秒事务数）
  - 数据传输量
- **脚手架模板**：新项目直接参考 [`project-template/test_cases/stress/load-test.js`](project-template/test_cases/stress/load-test.js) 起步，按目标接口改造阈值与压测阶梯；测试用例范例见 [`examples/test_cases/`](examples/test_cases/)
