压力测试脚本说明。用于验证 HTTP 接口在递增并发负载下的性能表现。创建于 2026-07-29。

## 环境准备

### 安装 k6

前往 https://k6.io/docs/getting-started/installation/ 获取对应操作系统的安装方式。常见方式：

macOS (Homebrew): `brew install k6`

Linux (apt): `sudo apt-get install k6`

Windows (Chocolatey): `choco install k6`

### 验证安装

```bash
k6 version
```

## 运行脚本

使用以下命令执行压测，将 TARGET_URL 替换为实际的测试地址：

```bash
k6 run --env TARGET_URL=http://localhost:8080/api/endpoint load-test.js
```

支持的环境变量：

- TARGET_URL: 目标接口地址（默认 http://localhost:8080/api/test）

## 输出指标说明

### 基础指标

- QPS / RPS (Requests Per Second): 每秒请求数，反映系统吞吐量。Target > 100。
- P95 (95 percentile latency): 95% 请求响应时间，单位 ms。Target < 300ms。
- P99 (99 percentile latency): 99% 请求响应时间，单位 ms。Target < 500ms。
- 错误率 (http_req_failed): 失败请求占比。Target < 1%。
- 并发 VU (Virtual Users): 虚拟用户数，模拟真实并发客户端。

### 自定义指标

- TPS (Transactions Per Second): 每秒交易数，通过 Counter 统计。
- data_received_bytes: 单个请求的响应体大小分布，通过 Trend 统计（展示中位数、P90、P95 等）。

## 备选工具

如需更复杂的场景（关联、断言、脚本调试），可考虑 JMeter；如仅需简洁的 HTTP 基准测试，可使用 wrk。

## 结果回填

测试完成后，k6 会输出完整的指标摘要。将如下关键数据记录到测试用例表：

- 最终通过/失败的请求数和错误率
- P95 和 P99 延迟
- 峰值 QPS
- 数据传输总量（data_received）

根据阈值对比判断是否满足性能要求。若超过阈值，应记录瓶颈分析结果（CPU/内存/网络/数据库等）。
