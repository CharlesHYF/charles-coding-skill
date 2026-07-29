# Charles Coding — DevOps 与部署安全
<!--
作用：Docker / 环境配置 / 云端部署安全基线分册，从 SKILL.md 下沉迁移
创建日期：2026-07-29
-->
> charles-coding 部署与运维规范分册。先遵循 [SKILL.md](../SKILL.md)。

### Docker 规范
- **强制使用 Docker Compose**：禁止手写 `docker run` 命令，所有容器编排通过 `docker-compose.yml`（或 `compose.yml`）管理
- **服务命名在最前**：`docker-compose.yml` 中每个服务必须显式定义 `container_name`，放在该服务定义的最前面，见名知义
- **数据持久化到项目目录**：所有容器数据目录必须挂载到项目根目录下的 `volumes/<服务名>/`，如 `./volumes/mysql:/var/lib/mysql`，禁止使用 Docker 匿名卷
- **容器时区东八区**：所有容器**强制**设置环境变量 `TZ=Asia/Shanghai`，确保容器时间为北京时间
- 示例：
  ```yaml
  services:
    db:
      container_name: myproject-mysql
      image: mysql:8.0
      environment:
        - TZ=Asia/Shanghai
      volumes:
        - ./volumes/mysql:/var/lib/mysql
  ```

### 环境与配置规范
- **三套环境齐全**：配置文件**必须**区分 **开发（dev）、测试（test）、生产（prod）** 三套环境，缺一不可；各环境的连接串、域名、密钥、开关等隔离，禁止用一份配置跑所有环境
- **配置文件由 Agent 主动创建与同步维护**：`.env` / `.env.*`、`application-*.yml` 等配置文件，**Agent 必须主动创建并随代码变更同步更新**（新增了需要的配置项就补进对应文件），**不许**让 Charles 自己手动补。含真实密钥的文件仍进 `.gitignore`，但要同步维护对应的 `*.example` 模板供参考
  - Java/Spring Boot：`application-dev.yml` / `application-test.yml` / `application-prod.yml` + `application.yml` 用 `spring.profiles.active` 切换
  - 前端（Vite/Next）：`.env.development` / `.env.test` / `.env.production`（详见各前端分册）
  - 其它语言按各自生态等义拆分（Go 的 config 目录分环境、Python 的 settings 分环境等）

### 云端部署安全基线
- **密钥/敏感配置绝不明文绝不入库**：生产配置中的敏感项（数据库密码、密钥、token 等）必须加密存储或托管——Spring Boot 用 Jasypt（`ENC(...)`）或接入配置中心（Nacos 加密 / Vault / KMS）；密钥与制品分离，不入库不进 git，仓库内只保留 `*.example` 模板
- **最小权限 + 网络收口**：服务默认内网监听，仅经网关/负载均衡对外；安全组/防火墙只放行必要端口；SSH 一律密钥登录，禁用密码登录；服务进程以非 root 用户运行
- **制品与源码分离**：服务器上只部署编译产物（jar/dist 等），不放 `.git`、源码目录、非 example 的配置模板；前端构建 sourcemap 不上生产
- **传输与静态加密**：对外一律 HTTPS/TLS；磁盘、备份按数据敏感级别按需加密
- 代码混淆（ProGuard/classfinal/xjar、前端混淆）**仅私有化交付/对外分发制品时适用**，内部云部署不强制
