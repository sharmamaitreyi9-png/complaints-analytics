-- =============================================================
-- 03_product_cuts.sql
-- Product-level slice of timely response, no-response rate,
-- relief granted rate, and average routing time.
-- =============================================================

SELECT
  product,
  COUNT(*) AS complaints,
  ROUND(100.0 * COUNT(CASE WHEN timely_response = TRUE THEN 1 END) / COUNT(*), 2) AS timely_pct,
  ROUND(100.0 * COUNT(CASE WHEN company_response IS NULL
                            OR  company_response = 'In progress' THEN 1 END) / COUNT(*), 2) AS no_response_pct,
  ROUND(100.0 * COUNT(CASE WHEN company_response IN (
      'Closed with monetary relief',
      'Closed with non-monetary relief'
  ) THEN 1 END) / COUNT(*), 2) AS relief_granted_pct,
  ROUND(AVG(days_to_route), 2) AS avg_days_to_route
FROM complaints_base
GROUP BY product
HAVING COUNT(*) > 5000
ORDER BY complaints DESC;
