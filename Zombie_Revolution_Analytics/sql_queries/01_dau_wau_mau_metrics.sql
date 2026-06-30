-- 1. Базовые метрики: DAU, WAU, MAU
SELECT
  date_trunc('day', start_session)::date AS day,
  date_trunc('week', start_session)::date AS week_start,
  date_trunc('month', start_session)::date AS month_start,
  count(DISTINCT id_user) AS dau
FROM skygame.game_sessions
GROUP BY 1,2,3
ORDER BY 1;
