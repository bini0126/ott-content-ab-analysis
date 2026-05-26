# 🎬 OTT 콘텐츠 노출 전략 분석

> MovieLens 25M 데이터를 기반으로 OTT 플랫폼의 콘텐츠 노출 전략이 유저 행동에 미치는 영향을 분석한 프로젝트입니다.

## 📌 프로젝트 개요

| 항목 | 내용 |
|---|---|
| 분석 목적 | 초기 노출 전략이 콘텐츠 장기 성과에 미치는 영향 검증 |
| 데이터 | MovieLens 25M (평점 2,500만 건, 영화 62,423개, 유저 162,541명) |
| 분석 기간 | 2026.05 |
| 사용 기술 | PostgreSQL, Python, Pandas, Scipy, Scikit-learn, Streamlit |

## 🔍 분석 내용

### 1. SQL 분석
- 장르별 평균 평점 분석 (CROSS JOIN, UNNEST)
- 연도별 영화 개봉 수 & 평균 평점 트렌드
- 유저 30일 재방문율 코호트 분석 (CTE, ROW_NUMBER, SELF JOIN)
- 인기 콘텐츠 vs 고품질 콘텐츠 비교 (FULL OUTER JOIN)
- 유저 세그먼트별 평점 패턴 분석

### 2. A/B 테스트
- **가설:** 초기 노출이 많은 콘텐츠가 최종 평균 평점이 더 높다
- **검증:** Independent t-test
- **결과:** p-value = 3.99e-15 (통계적으로 유의미한 차이 확인)
- **효과 크기:** Cohen's d = 0.20 (중간 효과)

### 3. 유저 세그먼트 분석
- K-Means 클러스터링으로 4개 유저 유형 도출
- Elbow Method로 최적 클러스터 수 결정

| 유저 유형 | 유저 수 | 특징 |
|---|---|---|
| 코어 마니아/아카이버 | 399명 | 평점수 2,207개, 활동기간 13년 |
| 장기 일반 헤비유저 | 7,639명 | 평점수 748개, 활동기간 7년 |
| 단기 이탈형 라이트유저 | 66,914명 | 평점수 151개, 활동기간 95일 |
| 신규 긍정형 유저 | 87,589명 | 평균평점 4.01로 가장 높음 |

## 💡 핵심 인사이트

1. **초기 노출 전략이 장기 성과에 유의미한 영향** — 초기 노출 많은 콘텐츠가 평균 평점 0.09점 높음 (p < 0.05)
2. **인기 콘텐츠 ≠ 고품질 콘텐츠** — 평점 수 상위 100개 중 77%가 평균 평점 상위 100개와 불일치
3. **30일 재방문율 35%** — 전체 유저의 65%가 한 번 오고 30일 내 미복귀
4. **헤비유저일수록 평가 기준이 까다로움** — 코어 마니아 평균 평점 3.30 vs 신규 유저 4.01

## 🛠 기술 스택
Database  : PostgreSQL 17
Language  : Python 3.12, SQL
Library   : Pandas, Numpy, Scipy, Scikit-learn, Matplotlib, Streamlit, SQLAlchemy
Tools     : DBeaver, VSCode, Git

## 📁 프로젝트 구조
    ott-content-ab-analysis/
    ├── sql/
    │   ├── 01_create_tables.sql       # 테이블 스키마 생성
    │   ├── 02_genre_rating_analysis.sql   # 장르별 평균 평점
    │   ├── 03_yearly_trend.sql        # 연도별 트렌드
    │   ├── 04_retention_analysis.sql  # 유저 재방문율
    │   ├── 05_popular_vs_quality.sql  # 인기 vs 품질 비교
    │   └── 06_user_segment_analysis.sql   # 유저 세그먼트
    ├── notebooks/
    │   ├── 01_ab_test.ipynb           # A/B 테스트 분석
    │   └── 02_user_segmentation.ipynb # 유저 세그먼트 분석
    └── dashboard/
    └── app.py                     # Streamlit 대시보드