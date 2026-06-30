-- 4. Сравнение средней продолжительности сессии по когортам (новый рекламный канал)
SELECT 
    CASE WHEN date_trunc('month', u.reg_date) BETWEEN date '2022-11-01' AND date '2022-12-01' THEN 'kogorta1' ELSE 'kogorta2' END AS kogorty,
    AVG(g.end_session - g.start_session) AS avg_session
FROM skygame.users u 
LEFT JOIN skygame.game_sessions g ON g.id_user = u.id_user
    AND g.end_session > g.start_session
    AND (g.end_session - g.start_session) > interval '5 minute'
GROUP BY kogorty
ORDER BY kogorty;
