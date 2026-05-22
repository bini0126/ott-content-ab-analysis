-- OTT 콘텐츠 분석 프로젝트 DB 세팅
-- MovieLens 25M 데이터셋 기반
-- 작성일: 2026-05-22

-- 1. 영화 테이블
CREATE TABLE movies (
    movie_id   INTEGER PRIMARY KEY,
    title      VARCHAR(500),
    genres     TEXT
);

-- 2. 평점 테이블 (Unix timestamp로 저장)
CREATE TABLE ratings (
    user_id    INTEGER,
    movie_id   INTEGER REFERENCES movies(movie_id),
    rating     NUMERIC(2,1),
    rated_at   INTEGER,
    PRIMARY KEY (user_id, movie_id)
);

-- 3. 태그 테이블
CREATE TABLE tags (
    user_id    INTEGER,
    movie_id   INTEGER REFERENCES movies(movie_id),
    tag        TEXT,
    tagged_at  INTEGER
);

-- 4. IMDb/TMDB 링크 테이블
CREATE TABLE links (
    movie_id   INTEGER PRIMARY KEY REFERENCES movies(movie_id),
    imdb_id    VARCHAR(20),
    tmdb_id    INTEGER
);

-- 5. 태그 목록 테이블
CREATE TABLE genome_tags (
    tag_id     INTEGER PRIMARY KEY,
    tag        TEXT
);

-- 6. 태그-영화 관련성 점수 테이블
CREATE TABLE genome_scores (
    movie_id   INTEGER REFERENCES movies(movie_id),
    tag_id     INTEGER REFERENCES genome_tags(tag_id),
    relevance  NUMERIC(10,8),
    PRIMARY KEY (movie_id, tag_id)
);

-- timestamp 변환 방법 (참고용)
-- SELECT to_timestamp(rated_at) FROM ratings LIMIT 5;