-- 분석 목적: 연도별 영화 개봉 수 및 평균 평점 트렌드
-- 비즈니스 질문: 연도별로 콘텐츠 양과 품질이 어떻게 변해왔는가?
-- 필터 조건: 개봉 수 10편 이상인 연도만 (소수 샘플 신뢰도 문제 제거)

SELECT SUBSTRING(m.title FROM '\((\d{4})\)') AS year, count(DISTINCT m.movie_id) as 개봉수, ROUND(AVG(r.rating)::numeric, 2) AS 평균평점 
FROM movies m
JOIN ratings r ON m.movie_id = r.movie_id
GROUP BY YEAR
HAVING count(DISTINCT m.movie_id) > 10
ORDER BY year asc;
