-- 1. Базовые метрики: DAU, WAU, MAU
SELECT
  date_trunc('day', start_session)::date AS day,
  date_trunc('week', start_session)::date AS week_start,
  date_trunc('month', start_session)::date AS month_start,
  count(DISTINCT id_user) AS dau
FROM skygame.game_sessions
GROUP BY 1,2,3
ORDER BY 1;

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

-- 5. Оценка вирусности (K-factor) и прогнозирование когорт с помощью CTE
WITH total_reg AS ( 
    SELECT sum(ref_reg) AS cnt_ref_reg 
    FROM skygame.users u
    LEFT JOIN skygame.referral r ON u.id_user = r.id_user
    WHERE r.ref_reg IS NOT NULL 
),
total_users AS (
    SELECT count(distinct id_user) AS cnt_total_users
    FROM skygame.users
),
k_factor AS (
    SELECT t1.cnt_ref_reg / t2.cnt_total_users AS k_factor
    FROM total_reg t1 CROSS JOIN total_users t2
),
avg_chrt_size AS (
    SELECT count(distinct id_user) / count(distinct date_trunc('month', reg_date)) AS avg_month_chrt
    FROM skygame.users
),
prognoz AS (
    SELECT k.k_factor, c.avg_month_chrt, k.k_factor * c.avg_month_chrt AS maybe_chrt_size
    FROM k_factor k CROSS JOIN avg_chrt_size c
)
SELECT * FROM prognoz;
