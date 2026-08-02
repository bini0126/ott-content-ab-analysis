SELECT
  "user_id",
  date_trunc('month', to_timestamp(min(timestamp))) AS first_rating_month
FROM ratings
GROUP BY "userId"

SELECT
  user_id,
  date_trunc('month', to_timestamp(MIN(rated_at))) AS first_rating_month
FROM ratings
GROUP BY user_id

WITH first_ratings AS (
  SELECT
    user_id,
    date_trunc('month', to_timestamp(MIN(rated_at))) AS first_rating_month
  FROM ratings
  GROUP BY user_id
),
all_activity AS (
  SELECT DISTINCT
    user_id,
    date_trunc('month', to_timestamp(rated_at)) AS activity_month
  FROM ratings
)
SELECT
  f.first_rating_month,
  (EXTRACT(YEAR FROM a.activity_month) - EXTRACT(YEAR FROM f.first_rating_month)) * 12
    + (EXTRACT(MONTH FROM a.activity_month) - EXTRACT(MONTH FROM f.first_rating_month)) AS months_since_first_rating,
  COUNT(DISTINCT f.user_id) AS active_users
FROM first_ratings f
JOIN all_activity a
  ON f.user_id = a.user_id
WHERE a.activity_month >= f.first_rating_month
GROUP BY f.first_rating_month, months_since_first_rating
ORDER BY f.first_rating_month, months_since_first_rating;

WITH first_ratings AS (
  SELECT
    user_id,
    date_trunc('month', to_timestamp(MIN(rated_at))) AS first_rating_month
  FROM ratings
  GROUP BY user_id
),
all_activity AS (
  SELECT DISTINCT
    user_id,
    date_trunc('month', to_timestamp(rated_at)) AS activity_month
  FROM ratings
),
joined AS (
  SELECT
    f.user_id,
    f.first_rating_month,
    (EXTRACT(YEAR FROM a.activity_month) - EXTRACT(YEAR FROM f.first_rating_month)) * 12
      + (EXTRACT(MONTH FROM a.activity_month) - EXTRACT(MONTH FROM f.first_rating_month)) AS months_since_first_rating
  FROM first_ratings f
  JOIN all_activity a
    ON f.user_id = a.user_id
  WHERE a.activity_month >= f.first_rating_month
)
SELECT
  first_rating_month,
  months_since_first_rating,
  COUNT(DISTINCT user_id) AS active_users
FROM joined
WHERE months_since_first_rating IN (0, 1, 3, 6, 12, 24)
GROUP BY first_rating_month, months_since_first_rating
ORDER BY first_rating_month, months_since_first_rating;
