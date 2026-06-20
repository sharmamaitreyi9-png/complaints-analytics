-- =============================================================
-- 04_company_risk_ranking.sql
-- Company-level risk ranking by untimely + no-response score,
-- followed by Amex vs. peer-bank benchmark.
-- =============================================================

-- Top 25 risk-ranked institutions (>= 1k complaints)
WITH company_stats AS (
  SELECT
    company,
    COUNT(*) AS complaints,
    100.0 * COUNT(CASE WHEN timely_response = FALSE THEN 1 END) / COUNT(*) AS untimely_pct,
    100.0 * COUNT(CASE WHEN company_response IS NULL
                        OR  company_response = 'In progress' THEN 1 END) / COUNT(*) AS no_response_pct,
    100.0 * COUNT(CASE WHEN company_response IN (
        'Closed with monetary relief',
        'Closed with non-monetary relief'
    ) THEN 1 END) / COUNT(*) AS relief_granted_pct,
    AVG(days_to_route) AS avg_days_to_route
  FROM complaints_base
  GROUP BY company
  HAVING COUNT(*) >= 1000
)
SELECT
  company,
  complaints,
  ROUND(untimely_pct, 2)       AS untimely_pct,
  ROUND(no_response_pct, 2)    AS no_response_pct,
  ROUND(relief_granted_pct, 2) AS relief_granted_pct,
  ROUND(avg_days_to_route, 2)  AS avg_days_to_route,
  RANK() OVER (ORDER BY untimely_pct    DESC) AS untimely_rank,
  RANK() OVER (ORDER BY no_response_pct DESC) AS no_response_rank
FROM company_stats
ORDER BY (untimely_pct + no_response_pct) DESC
LIMIT 25;

-- American Express vs. peer banks
WITH company_stats AS (
  SELECT
    company,
    COUNT(*) AS complaints,
    ROUND(100.0 * COUNT(CASE WHEN timely_response = FALSE THEN 1 END) / COUNT(*), 2) AS untimely_pct,
    ROUND(100.0 * COUNT(CASE WHEN company_response IS NULL
                              OR  company_response = 'In progress' THEN 1 END) / COUNT(*), 2) AS no_response_pct,
    ROUND(100.0 * COUNT(CASE WHEN company_response IN (
        'Closed with monetary relief',
        'Closed with non-monetary relief'
    ) THEN 1 END) / COUNT(*), 2) AS relief_granted_pct,
    ROUND(AVG(days_to_route), 2) AS avg_days_to_route
  FROM complaints_base
  GROUP BY company
)
SELECT *
FROM company_stats
WHERE company ILIKE '%american express%'
   OR company ILIKE '%jpmorgan%'
   OR company =       'CITIBANK, N.A.'
   OR company ILIKE '%capital one%'
   OR company ILIKE '%discover%'
   OR company ILIKE '%bank of america%'
   OR company ILIKE '%wells fargo%'
ORDER BY complaints DESC;
