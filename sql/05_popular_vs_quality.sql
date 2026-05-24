-- ================================================================
-- 분석 목적: 인기 콘텐츠 vs 고품질 콘텐츠 비교 분석
-- 비즈니스 질문: 많이 본 영화와 잘 만든 영화는 일치하는가?
-- 핵심 인사이트: 인기도와 품질 불일치율 77% 
--               → 단순 인기도 기반 추천은 유저 만족도 보장 못함
--               → 추천 알고리즘에 평균 평점 가중치 추가 필요
-- ================================================================

-- 평점 수 상위 100개 영화
select  m.title as 영화제목, count(*) as "평점 수" from movies m
join ratings r on m.movie_id = r.movie_id
group by m.movie_id 
order by "평점 수" desc limit 100;


-- 평균 평점 상위 100개 영화
select m.title as 영화제목, round(avg(r.rating), 2) as "평균 점수" from movies m
join ratings r on m.movie_id = r.movie_id
group by m.movie_id 
having count(*) >= 400
order by "평균 점수" desc limit 100;


-- 합치기
with 평점수상위 as(select  m.title as 영화제목, count(*) as "평점 수" from movies m
	join ratings r on m.movie_id = r.movie_id
	group by m.movie_id 
	order by "평점 수" desc limit 100),
평균평점상위 as (select m.title as 영화제목, round(avg(r.rating), 2) as "평균 점수" from movies m
	join ratings r on m.movie_id = r.movie_id
	group by m.movie_id 
	having count(*) >= 400
	order by "평균 점수" desc limit 100)
SELECT 
    COALESCE(a.영화제목, b.영화제목) AS 영화제목,
    a."평점 수",
    b."평균 점수",
    CASE WHEN a.영화제목 IS NOT NULL AND b.영화제목 IS NOT NULL 
         THEN '✓ 겹침' 
         ELSE '-' 
    END AS 겹침여부
FROM 평점수상위 a
FULL OUTER JOIN 평균평점상위 b ON a.영화제목 = b.영화제목
ORDER BY 
    겹침여부 DESC,  -- ✓ 겹침이 먼저
    a."평점 수" DESC NULLS LAST,
    b."평균 점수" DESC NULLS LAST;
	
