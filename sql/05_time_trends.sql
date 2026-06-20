-- =============================================================
-- 05_time_trends.sql
-- Monthly volume + untimely + relief-granted trend, 2020 onward.
-- Surfaces the ~15x post-2020 volume rise and post-2024
-- collapse in monetary / non-monetary relief share.
-- =============================================================

SELECT
  DATE_TRUNC('month', date_received) AS month,
  COUNT(*) AS complaints,
  ROUND(100.0 * COUNT(CASE WHEN timely_response = FALSE THEN 1 END) / COUNT(*), 2) AS untimely_pct,
  ROUND(100.0 * COUNT(CASE WHEN company_response IN (
      'Closed with monetary relief',
      'Closed with non-monetary relief'
  ) THEN 1 END) / COUNT(*), 2) AS relief_pct
FROM complaints_base
WHERE date_received >= '2020-01-01'
  AND date_received <  '2026-06-01'
GROUP BY 1
ORDER BY 1;
