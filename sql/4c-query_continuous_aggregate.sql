-- ============================================================================
-- ## Query the continuous aggregate
-- ============================================================================
SELECT *
FROM halfday_summary
WHERE full_name = 'mixing.reactor_01.agitator_01.speed'
  AND period >= NOW() - INTERVAL '14 DAYS'
ORDER BY period DESC;

-- Add some data to a new interval
INSERT INTO tag_history (time, id, value, quality)
VALUES (NOW()+ INTERVAL '12 HOURS' , 1, 500, 192);

-- Verify that the result is updated
SELECT *
FROM halfday_summary
WHERE full_name = 'mixing.reactor_01.agitator_01.speed'
  AND period >= NOW() - INTERVAL '14 DAYS'
ORDER BY period DESC;
