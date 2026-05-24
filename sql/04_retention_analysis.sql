-- ================================================================
-- 분석 목적: 유저 30일 재방문율 코호트 분석
-- 비즈니스 질문: 전체 유저 중 30일 이내에 재방문하는 유저 비율은?
-- 인사이트: 단순 재방문율(81%)과 전체 기반 재방문율(35%) 차이 확인
-- ================================================================

-- STEP 1. 유저별 날짜 단위로 중복 제거
-- (같은 날 여러 번 평점 줘도 하루로 묶음)
WITH 날짜별평점 AS (
    SELECT 
        user_id,
        DATE(to_timestamp(rated_at)) AS 평점날짜
    FROM ratings
    GROUP BY user_id, DATE(to_timestamp(rated_at))
),

-- STEP 2. 유저별 방문 순서 매기기 (ROW_NUMBER 윈도우 함수)
순서매기기 AS (
    SELECT 
        user_id,
        평점날짜,
        ROW_NUMBER() OVER (
            PARTITION BY user_id 
            ORDER BY 평점날짜 ASC
        ) AS rn
    FROM 날짜별평점
), 

-- STEP 3. 첫 방문 & 두 번째 방문 날짜를 같은 행에 붙이기 (SELF JOIN)
첫두번째 AS (
    SELECT 
        a.user_id,
        a.평점날짜 AS 첫방문,
        b.평점날짜 AS 두번째방문,
        b.평점날짜 - a.평점날짜 AS 날짜차이
    FROM 순서매기기 a
    JOIN 순서매기기 b 
        ON a.user_id = b.user_id
        AND a.rn = 1
        AND b.rn = 2
)

-- STEP 4. 전체 유저 기반 30일 이내 재방문율 계산
-- 주의: 분모를 두 번 이상 방문한 유저가 아닌 전체 유저로 설정
SELECT
    (SELECT COUNT(DISTINCT user_id) FROM ratings) AS 전체유저수,
    COUNT(CASE WHEN 날짜차이 <= 30 THEN 1 END) AS 재방문유저수,
    ROUND(
        COUNT(CASE WHEN 날짜차이 <= 30 THEN 1 END) * 100.0 
        / (SELECT COUNT(DISTINCT user_id) FROM ratings),
        2
    ) AS 재방문율퍼센트
FROM 첫두번째;