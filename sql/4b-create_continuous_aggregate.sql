-- This statement is in a file of its own on purpose. Building a continuous
-- aggregate can't happen inside a transaction, and `tiger db query -f` runs a
-- file with several statements as one transaction. On its own it runs fine.

-- ============================================================================
-- ## Continuous aggregates
-- ============================================================================
-- A continuous aggregate is a materialized view that auto-updates as new
-- data arrives. You query it like a regular table, but it's pre-computed.
CREATE MATERIALIZED VIEW halfday_summary
WITH (timescaledb.continuous, timescaledb.materialized_only = false) AS
SELECT
    tag_meta.id,
    tag_meta.full_name,
    time_bucket('12 HOUR', time) AS period, --time_bucket is a timescaledb function
    AVG(value) AS avg_value,
    tag_meta.units
FROM tag_history
JOIN tag_meta ON tag_history.id = tag_meta.id
GROUP BY tag_meta.id,period
ORDER BY period DESC;
