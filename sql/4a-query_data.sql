-- ============================================================================
-- ## Drop existing views (safe to re-run)
-- ============================================================================
DROP MATERIALIZED VIEW IF EXISTS halfday_summary;

-- ============================================================================
-- ## Query Data
-- ============================================================================
-- a typical dashboard query would be averaging a specific tag over a given time
-- period.
SELECT
    id,
    time_bucket('12 HOUR', time) AS period, --time_bucket is a timescaledb function
    AVG(value) AS avg_value,
    MAX(value) AS max_value,
    MIN(value) AS min_value
FROM tag_history
WHERE time >= NOW() - INTERVAL '14 days'
    AND id=1
GROUP BY id, period
ORDER BY id, period DESC;

-- ============================================================================
-- ## JOIN Tables
-- ============================================================================
-- By joining multiple tables, we can get full context
SELECT
    tag_meta.id,
    tag_meta.full_name,
    time_bucket('12 HOUR', time) AS period, --time_bucket is a timescaledb function
    AVG(value) AS avg_value,
    tag_meta.units   --add units
FROM tag_history
JOIN tag_meta ON tag_history.id = tag_meta.id
WHERE time >= NOW() - INTERVAL '14 days'
    AND tag_meta.full_name = 'filling.filler_01.pump_01.total_volume'
GROUP BY tag_meta.id,period
ORDER BY tag_meta.full_name,period DESC;
