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
