/*
 * @description 基础 HTTP 接口压力测试脚本，验证系统在递增并发下的性能表现
 * @author Charles
 * @date 2026-07-29
 */

import http from 'k6/http';
import { check, Counter, Trend } from 'k6';

// 自定义指标
const tps = new Counter('tps');
const dataReceivedBytes = new Trend('data_received_bytes');

export const options = {
	// 阶梯加压：0-1min 1VU -> 1-2min 10VU -> 2-3min 20VU -> 3-4min 10VU -> 4-5min 0VU
	stages: [
		{ duration: '1m', target: 1 },
		{ duration: '1m', target: 10 },
		{ duration: '1m', target: 20 },
		{ duration: '1m', target: 10 },
		{ duration: '1m', target: 0 },
	],
	// 性能阈值
	thresholds: {
		'http_req_failed': ['<0.01'],		// 错误率 < 1%
		'http_req_duration': ['p(95)<300', 'p(99)<500'],	// P95<300ms, P99<500ms
		'http_reqs': ['rate>100'],			// QPS > 100
	},
};

export default function () {
	// 构造请求 URL（目标地址由环境变量 TARGET_URL 指定）
	const targetUrl = __ENV.TARGET_URL || 'http://localhost:8080/api/test';

	// 发起 GET 请求
	const res = http.get(targetUrl);

	// 记录 TPS 和数据传输量
	tps.add(1);
	dataReceivedBytes.add(res.body ? res.body.length : 0);

	// 验证响应状态码为 200
	check(res, {
		'status is 200': (r) => r.status === 200,
	});
}
