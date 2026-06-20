-- =============================================================
-- 06_channel_geo.sql
-- Channel mix + state-level relief distribution.
-- =============================================================

-- Channel mix
SELECT
  submitted_via,
  COUNT(*) AS complaints,
  ROUND(AVG(days_to_route), 2) AS avg_days_to_route,
  ROUND(100.0 * COUNT(CASE WHEN timely_response = TRUE THEN 1 END) / COUNT(*), 2) AS timely_pct,
  ROUND(100.0 * COUNT(CASE WHEN company_response IN (
      'Closed with monetary relief',
      'Closed with non-monetary relief'
  ) THEN 1 END) / COUNT(*), 2) AS relief_pct
FROM complaints_base
GROUP BY 1
ORDER BY 2 DESC;

-- Top 15 states by volume
SELECT
  state,
  COUNT(*) AS complaints,
  ROUND(100.0 * COUNT(CASE WHEN company_response IN (
      'Closed with monetary relief',
      'Closed with non-monetary relief'
  ) THEN 1 END) / COUNT(*), 2) AS relief_pct
FROM complaints_base
WHERE state IS NOT NULL
  AND LENGTH(state) = 2
GROUP BY 1
ORDER BY 2 DESC
LIMIT 15;
