/**
 * 前端 Lint 规则，承接 charles-coding 里 Prettier 管不到的排版与约束
 * 创建日期：2026-09-21
 * 修改日期：2026-09-24
 */
export default [
	{
		files: ["**/*.{js,jsx,ts,tsx,vue}"],
		rules: {
			"padding-line-between-statements": [
				"error",
				{ blankLine: "always", prev: "*", next: "return" },
			],
			"lines-between-class-members": ["error", "always"],
			"object-curly-newline": ["error", { multiline: true, consistent: true }],
			"no-magic-numbers": [
				"error",
				{
					ignore: [0, 1, -1],
					ignoreArrayIndexes: true,
					enforceConst: true,
					detectObjects: false,
				},
			],
			"no-nested-ternary": "error",
			"no-var": "error",
			eqeqeq: ["error", "always"],
			"no-restricted-imports": [
				"error",
				{
					patterns: [],
				},
			],
		},
	},
];
