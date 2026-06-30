-- 3. Анализ технических сбоев (доля битых сессий по устройствам)
SELECT
  u.dev_type,
  COUNT(*) AS broken_sessions,
  1.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS broken_share_among_broken
FROM skygame.game_sessions gs
JOIN skygame.users u ON u.id_user = gs.id_user
WHERE gs.end_session IS NULL
GROUP BY 1
ORDER BY 1;
