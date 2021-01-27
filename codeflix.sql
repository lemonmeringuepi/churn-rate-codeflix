--exploration
SELECT *
FROM subscriptions
LIMIT 10;

SELECT DISTINCT segment
FROM subscriptions;

SELECT MIN(subscription_start) AS first_sub,
  MAX(subscription_start) AS latest_sub,
  MAX(subscription_end) AS latest_cancel
FROM subscriptions;

--calculate churn rate
WITH months AS
(SELECT '2017-01-01' AS first_date,
  '2017-01-31' AS last_date
UNION
SELECT '2017-02-01' AS first_date,
  '2017-02-28' AS last_date
UNION
SELECT '2017-03-01' AS first_date,
  '2017-03-31' AS last_date
),
cross_join AS
(SELECT *
FROM subscriptions
CROSS JOIN months
),
status AS
(SELECT id,
  first_date AS month,
  segment,
  CASE
    WHEN (subscription_start < first_date
      AND (subscription_end > first_date
        OR subscription_end IS NULL))
    THEN 1
    ELSE 0
  END AS is_active,
  CASE
    WHEN subscription_end BETWEEN first_date AND last_date
      THEN 1
      ELSE 0
  END AS is_canceled
FROM cross_join
),
status_aggregate AS
(SELECT month,
  segment,
  SUM(is_active) AS sum_active,
  SUM(is_canceled) AS sum_canceled
FROM status
GROUP BY 2, 1
)
SELECT month,
  segment,
  ROUND(100.0 * sum_canceled / sum_active, 0) AS churn
FROM status_aggregate;


--interesting. Is there a difference in segment size? No.
WITH months AS
(SELECT '2017-01-01' AS first_date,
  '2017-01-31' AS last_date
UNION
SELECT '2017-02-01' AS first_date,
  '2017-02-28' AS last_date
UNION
SELECT '2017-03-01' AS first_date,
  '2017-03-31' AS last_date
),
cross_join AS
(SELECT *
FROM subscriptions
CROSS JOIN months
),
status AS
(SELECT id,
  first_date AS month,
  segment,
  CASE
    WHEN (subscription_start < first_date
      AND (subscription_end > first_date
        OR subscription_end IS NULL))
    THEN 1
    ELSE 0
  END AS is_active,
  CASE
    WHEN subscription_end BETWEEN first_date AND last_date
      THEN 1
      ELSE 0
  END AS is_canceled
FROM cross_join
)
SELECT month,
  segment,
  SUM(is_active) AS sum_active,
  SUM(is_canceled) AS sum_canceled
FROM status
GROUP BY 2, 1;