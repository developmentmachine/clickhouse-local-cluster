# ClickHouse 本地三分片集群

该目录提供一套适用于本地 Docker 环境的 ClickHouse 集群部署，结构为：

- ClickHouse `22.3.2.2` LTS（三个节点、三个分片、每分片一个副本）
- ZooKeeper `3.8.4`（三个节点）
- ClickHouse 原生 TCP 端口使用文档中的 `9027`
- 所有宿主机端口仅绑定 `127.0.0.1`
- 数据、日志和配置全部保存在当前目录

文档截图中的客户端版本为 `22.3.2.1`；Docker 部署采用同一补丁系列的官方 `22.3.2.2` LTS 镜像。

## 目录

```text
config/   ClickHouse 集群、宏、用户和可选 OSS 配置
data/     ClickHouse 与 ZooKeeper 持久化数据
logs/     ClickHouse 日志
scripts/  初始化和状态检查脚本
sql/      演示数据库与分布式表 SQL
```

## 启动

```bash
cd /Users/bountyhunter/DevelopmentWorkspaces/clickhouse-local-cluster
docker compose up -d
./scripts/status.sh
./scripts/bootstrap.sh
```

Apple Silicon 会通过 `linux/amd64` 兼容模式运行旧版 ClickHouse，首次拉取和首次启动会比原生 ARM 镜像慢。

## 连接

本地默认用户为 `default`，密码为空。宿主机端口只绑定 `127.0.0.1`；如需开放给其他机器，请先配置密码和网络访问范围。

节点一：

```bash
docker compose exec clickhouse-01 clickhouse-client --port 9027
```

宿主机已安装 `clickhouse-client` 时：

```bash
clickhouse-client --host 127.0.0.1 --port 9027
```

端口映射：

| 节点 | HTTP | TCP |
|---|---:|---:|
| clickhouse-01 | 8123 | 9027 |
| clickhouse-02 | 8124 | 9028 |
| clickhouse-03 | 8125 | 9029 |

ZooKeeper 宿主机端口为 `2181`、`2182`、`2183`。

## 常用命令

```bash
make ps
make status
make bootstrap
make client
make logs
make down
```

查看集群：

```sql
SELECT *
FROM system.clusters
WHERE cluster = 'ck_cluster'
ORDER BY shard_num;
```

查看节点宏：

```sql
SELECT * FROM system.macros;
```

## OSS 存储

`config/common/oss-storage.xml.example` 是文档中阿里云 OSS 存储策略的本地模板。由于文档中的 AccessKey 是占位符，默认不会加载该文件，也不会把无效密钥写入运行配置。

启用前：

1. 将示例复制为 `config/common/oss-storage.xml`。
2. 填写自己的 OSS endpoint、AccessKey ID 和 AccessKey Secret。
3. 在三个 ClickHouse 服务的 `volumes` 中增加：

```yaml
- ./config/common/oss-storage.xml:/etc/clickhouse-server/config.d/oss-storage.xml:ro
```

4. 重启集群，并建表时使用：

```sql
SETTINGS storage_policy = 'OSS'
```

不要提交真实 AccessKey；`.gitignore` 已忽略启用后的 OSS 配置文件。

## 停止与清理

停止但保留数据：

```bash
docker compose down
```

删除本地数据前请自行确认，然后执行：

```bash
docker compose down
rm -rf data logs
```
