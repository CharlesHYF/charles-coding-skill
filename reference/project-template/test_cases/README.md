<!--
	文件作用：测试用例目录说明 —— 新项目按此结构组织测试用例
	创建日期：2026-08-01
	说明：详细范例见 reference/examples/test_cases/，正式项目需按模块补齐全部用例
-->
# test_cases/ 目录说明

> 按**系统模块（backend / frontend / daemon）→ 测试类型（unit / smoke / e2e / blackbox / whitebox）**两级目录组织测试用例。

```
test_cases/
├── backend/
│   ├── unit/          # 后端单元测试（login、user、order 等，按功能模块分文件）
│   ├── smoke/         # 后端冒烟测试
│   ├── blackbox/      # 后端黑盒测试
│   └── whitebox/      # 后端白盒测试
├── frontend/
│   ├── unit/          # 前端单元测试（组件渲染、交互）
│   ├── smoke/         # 前端冒烟测试
│   └── e2e/           # 前端端到端测试
├── daemon/
│   ├── unit/          # 守护进程单元测试
│   └── smoke/         # 守护进程冒烟测试
└── stress/            # 压力/性能测试
    ├── README.md
    └── load-test.js
```

## 要求
- 每个模块的**每个功能（func）都要写测试用例**，覆盖正向、异常、边界、并发场景
- 测试用例表格格式见 [reference/testing.md](../../testing.md)
- 详细范例参考 [reference/examples/test_cases/](../../examples/test_cases/)

## 占位文件
新项目初始化后，在各目录下创建 `.gitkeep` 占位，待功能开发后逐个填写测试用例。
