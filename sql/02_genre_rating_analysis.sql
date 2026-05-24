-- 분석 목적: 장르별 평균 평점 분석
-- 비즈니스 질문: 어떤 장르가 가장 높은 평가를 받는가?
-- 결과 활용: 콘텐츠 투자 우선순위 결정에 활용 가능

SELECT 
    TRIM(genre) AS 장르,
    COUNT(*) AS 평점수,
    ROUND(AVG(r.rating)::numeric, 2) AS 평균평점
FROM movies m
JOIN ratings r ON m.movie_id = r.movie_id
CROSS JOIN UNNEST(STRING_TO_ARRAY(m.genres, '|')) AS genre
GROUP BY TRIM(genre)
HAVING COUNT(*) > 1000
ORDER BY 평균평점 DESC;