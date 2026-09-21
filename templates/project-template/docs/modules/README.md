<!--
	模块文档目录说明  --  新项目按此结构组织模块文档
	创建日期：2026-08-01
	说明：详细范例见 charles-coding skill 的 templates/examples/docs/modules/，正式项目需为每个模块编写文档
-->
# docs/modules/ 目录说明

> 按**系统模块（backend / frontend / daemon）**划分子目录，每个功能模块一个 `.md`。

```
docs/modules/
├── README.md          # 本说明文件
├── backend/           # 后端模块文档（auth.md、order.md、user.md 等）
├── frontend/          # 前端模块文档（login.md、dashboard.md 等）
└── daemon/            # 守护进程模块文档（scheduler.md 等）
```

## 要求
- 编码前**必须**先写模块文档，评审通过后再进入编码
- 文档模板见 charles-coding skill 的 `templates/module-doc.md`
- 每个功能包含：功能描述、接口信息、入参要求、返回、业务流程（Mermaid）、异常与错误码、数据库表/字段
- 文档随功能变更同步更新，代码实现须与文档一致
- 详细范例参考 charles-coding skill 的 `templates/examples/docs/modules/`
