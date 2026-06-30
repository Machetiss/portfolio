-- 1. Базовые метрики: DAU, WAU, MAU
-- (Примечание: Первые два дня выборки, 2 и 3 июля, исключены, так как они 
-- попадают на неполную 26-ю неделю и создают выбросы на графике Sticky Factor).
SELECT
  date_trunc('day', start_session)::date AS day,
  date_trunc('week', start_session)::date AS week_start,
  date_trunc('month', start_session)::date AS month_start,
  count(DISTINCT id_user) AS dau
FROM skygame.game_sessions
WHERE start_session >= DATE '2022-07-04'
GROUP BY 1,2,3
ORDER BY 1;
