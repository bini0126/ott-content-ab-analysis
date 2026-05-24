-- ================================================================
-- 분석 목적: 유저 세그먼트별 평점 패턴 분석
-- 비즈니스 질문: 헤비유저와 라이트유저의 평점 패턴이 어떻게 다른가?
-- 핵심 인사이트: 헤비유저일수록 평균 평점이 낮아지는 경향 (헤비 3.52 < 라이트 3.71)
--               → 많이 본 유저일수록 평가 기준이 까다로워짐
--               → 헤비유저 대상 추천은 인기작보다 장르 취향 기반 개인화 추천이 효과적
-- 세그먼트 기준: 헤비(200개 이상) / 미들(50~199개) / 라이트(50개 미만)
-- 참고: MovieLens 데이터는 최소 20개 이상 평점 유저만 포함
-- ================================================================

-- 유저별 평점 수
select user_id as 유저, count(*) as "평점 수" from ratings
group by user_id
order by user_id asc;

-- 세그먼트 분류
select user_id as 유저, (CASE 
    WHEN count(*) >= 200 THEN '헤비유저'
    WHEN count(*) >= 50 THEN '미들유저'
    ELSE '라이트유저'
end) AS 세그먼트 from ratings
group by user_id
order by user_id asc;

SELECT MIN(count) FROM (
    SELECT COUNT(*) as count 
    FROM ratings 
    GROUP BY user_id
) t;

-- 세그먼트별 통계
WITH 유저세그먼트 AS (
    SELECT 
        user_id,
        COUNT(*) AS 평점수,
        ROUND(AVG(rating)::numeric, 2) AS 평균평점,
        CASE 
            WHEN COUNT(*) >= 200 THEN '헤비유저'
            WHEN COUNT(*) >= 50 THEN '미들유저'
            ELSE '라이트유저'
        END AS 세그먼트
    FROM ratings
    GROUP BY user_id
)
SELECT
    세그먼트,
    COUNT(*) AS 유저수,
    ROUND(AVG(평점수), 1) AS 평균평점수,
    ROUND(AVG(평균평점)::numeric, 2) AS 평균평점
FROM 유저세그먼트
GROUP BY 세그먼트
ORDER BY 평균평점수 DESC;

