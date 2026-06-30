-- 2. Поиск лояльных пользователей для начисления бонусов (когорта 2022)
SELECT
  u.id_user,
  u.reg_date,
  SUM(EXTRACT(EPOCH FROM (gs.end_session - gs.start_session)) / 60.0) AS sessions_minutes
FROM skygame.users u
JOIN skygame.game_sessions gs ON gs.id_user = u.id_user
WHERE gs.end_session IS NOT NULL
  AND u.reg_date >= DATE '2022-01-01' AND u.reg_date < DATE '2023-01-01'
GROUP BY 1,2
ORDER BY sessions_minutes DESC
LIMIT 25;
