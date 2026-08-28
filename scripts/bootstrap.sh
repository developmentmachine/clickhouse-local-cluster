#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir"

docker compose exec -T clickhouse-01 \
  clickhouse-client --port 9027 --multiquery \
  < sql/bootstrap.sql
