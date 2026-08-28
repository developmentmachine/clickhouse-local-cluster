CREATE DATABASE IF NOT EXISTS local_cluster ON CLUSTER ck_cluster;

CREATE TABLE IF NOT EXISTS local_cluster.events_local ON CLUSTER ck_cluster
(
    event_date Date,
    shard UInt8,
    value String
)
ENGINE = MergeTree
ORDER BY (event_date, shard, value);

CREATE TABLE IF NOT EXISTS local_cluster.events_all ON CLUSTER ck_cluster
AS local_cluster.events_local
ENGINE = Distributed(ck_cluster, local_cluster, events_local, shard);

TRUNCATE TABLE local_cluster.events_local ON CLUSTER ck_cluster;

SET insert_distributed_sync = 1;

INSERT INTO local_cluster.events_all
SELECT
    today(),
    toUInt8(number % 3 + 1),
    concat('row-', toString(number))
FROM numbers(12);

SELECT
    hostName() AS host,
    count() AS rows
FROM cluster(ck_cluster, local_cluster.events_local)
GROUP BY host
ORDER BY host;
