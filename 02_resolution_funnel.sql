-- =============================================================
-- 02_resolution_funnel.sql
-- 5-stage complaint resolution funnel:
--   received -> routed -> responded -> timely -> resolved
-- =============================================================

WITH funnel AS (
  SELECT
    COUNT(*) AS received,
    COUNT(CASE WHEN date_sent_to_company IS NOT NULL THEN 1 END) AS routed,
    COUNT(CASE WHEN company_response IS NOT NULL
               AND  company_response != 'In progress' THEN 1 END) AS responded,
    COUNT(CASE WHEN timely_response = TRUE THEN 1 END)            AS responded_timely,
    COUNT(CASE WHEN company_response IN (
        'Closed with explanation',
        'Closed with monetary relief',
        'Closed with non-monetary relief'
    ) THEN 1 END) AS closed_resolved
  FROM complaints_base
)
SELECT
  received,
  routed,            ROUND(100.0 * routed            / received, 2) AS routed_pct,
  responded,         ROUND(100.0 * responded         / received, 2) AS responded_pct,
  responded_timely,  ROUND(100.0 * responded_timely  / received, 2) AS timely_pct,
  closed_resolved,   ROUND(100.0 * closed_resolved   / received, 2) AS resolved_pct
FROM funnel;
