-- =============================================================
-- 01_base_table.sql
-- Builds the cleaned base table from the raw CFPB CSV.
-- Source: https://files.consumerfinance.gov/ccdb/complaints.csv.zip
-- =============================================================

-- Load raw CSV
CREATE OR REPLACE TABLE complaints_raw AS
SELECT *
FROM read_csv_auto(
  'C:\Users\rajiv\projects\complaints-analytics\data\complaints.csv',
  header=true,
  parallel=false
);

-- Cleaned base table with normalized column names and routing metric
CREATE OR REPLACE TABLE complaints_base AS
SELECT
  "Complaint ID"                                  AS complaint_id,
  CAST("Date received"        AS DATE)            AS date_received,
  CAST("Date sent to company" AS DATE)            AS date_sent_to_company,
  "Product"                                       AS product,
  "Sub-product"                                   AS sub_product,
  "Issue"                                         AS issue,
  "Sub-issue"                                     AS sub_issue,
  "Company"                                       AS company,
  "State"                                         AS state,
  "Submitted via"                                 AS submitted_via,
  "Company response to consumer"                  AS company_response,
  "Timely response?"                              AS timely_response,
  DATE_DIFF(
    'day',
    CAST("Date received"        AS DATE),
    CAST("Date sent to company" AS DATE)
  ) AS days_to_route
FROM complaints_raw
WHERE "Date received" IS NOT NULL;

-- Validation
SELECT COUNT(*)                                  AS row_count       FROM complaints_base;
SELECT MIN(date_received), MAX(date_received)                       FROM complaints_base;
SELECT product, COUNT(*) AS c FROM complaints_base GROUP BY 1 ORDER BY 2 DESC LIMIT 10;
