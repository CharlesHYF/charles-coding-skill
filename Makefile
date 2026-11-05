# 提供仓库常用操作入口
# 创建日期：2026-11-05
# 修改日期：2026-11-05

.PHONY: sync author commit push publish-release rebase

# ---------------------- 技能同步 ----------------------

sync:
	@bash tools/git-commands.sh sync

# ---------------------- Git 与发布 ----------------------

author commit publish-release rebase:
	@bash tools/git-commands.sh $@ $(foreach arg,$(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS)),'$(arg)')

push:
	@git push origin main:main

ifneq ($(filter author commit publish-release rebase,$(firstword $(MAKECMDGOALS))),)
%:
	@:
endif
