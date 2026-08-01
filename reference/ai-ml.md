# Charles Coding — AI / ML
> charles-coding 的 AI/ML 分册。先遵循 [SKILL.md](../SKILL.md) 的全局约定。

<!--
文件作用：AI/ML 分册，覆盖模型训练/推理、数据处理管道、LLM 应用集成等场景的编码约定
创建日期：2026-07-29
-->

## 能力范围
- 模型训练与推理（传统机器学习、深度学习）
- 数据处理管道（清洗、特征工程、批处理/流处理）
- LLM 应用集成（Prompt 工程、RAG、Agent、向量检索）

## 技术栈与工具
- 版本：Python 3.10+
- 深度学习框架：PyTorch（默认首选）；轻量任务可用 scikit-learn
- 数据处理：pandas / numpy
- 实验管理：MLflow 或 Weights & Biases（可选，复杂项目建议接入）
- 包管理与虚拟环境：首选 **uv**，使用 `pyproject.toml` 管理依赖，与 Python 分册一致

## 目录布局
```
project/
├── data/          # 原始与处理后数据（大文件不入 git）
├── notebooks/      # 探索性分析，交付前清除 output
├── src/           # 核心代码（数据管道、模型定义、训练/推理脚本）
├── models/        # 训练产出的模型文件（不入 git，走 DVC/LFS 或对象存储）
├── experiments/   # 实验记录（超参、指标、对应 commit）
└── configs/       # 训练/推理配置（YAML/JSON）
```

## 文件头部模板
```python
# -*- coding: utf-8 -*-
"""
文件作用：简要描述本文件职责，一到两句话，句号结尾。
创建日期：YYYY-MM-DD
修改日期：YYYY-MM-DD
"""
```

## 约定与坑
- 实验可复现：固定随机种子（Python/numpy/框架三处都要设置）；依赖锁定（`uv.lock` 提交入库）；每次实验记录超参与指标（手工记录或借助 MLflow/W&B）
- 数据与代码分离：大文件与数据集不入 git，使用 DVC 或 Git LFS 管理；`.gitignore` 排除 `data/` `models/` 下的大文件
- notebook 交付前必须清除 output（`jupyter nbconvert --clear-output` 或等效工具），避免污染 diff 与泄露数据
- 模型版本与评估指标必须记录：每次训练产出关联 commit hash、数据版本、评估指标，便于回溯与对比
- 敏感数据脱敏：训练/日志中的用户隐私字段（手机号、身份证、地址等）必须脱敏后再落盘或上传

## 测试
- 数据管道单测：对清洗、特征工程等关键步骤编写单元测试，覆盖边界值与异常输入
- 指标回归阈值：模型评估指标（准确率/F1/AUC 等）不得低于基线，纳入 CI 检查，与 [reference/testing.md](./testing.md) 呼应
