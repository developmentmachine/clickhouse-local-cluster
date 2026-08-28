#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir"

docker compose ps

echo
echo "ClickHouse cluster:"
docker compose exec -T clickhouse-01 clickhouse-client --port 9027 --query \
  "SELECT cluster, shard_num, replica_num, host_name, port, is_local FROM system.clusters WHERE cluster = 'ck_cluster' ORDER BY shard_num"

echo
echo "Node macros:"
for node in clickhouse-01 clickhouse-02 clickhouse-03; do
  docker compose exec -T "$node" clickhouse-client --port 9027 --query \
    "SELECT hostName(), macro, substitution FROM system.macros ORDER BY macro"
done
