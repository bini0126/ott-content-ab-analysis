# -*- coding: utf-8 -*-
import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
from sqlalchemy import create_engine, text
from urllib.parse import quote_plus

# 한글 폰트 설정
plt.rcParams['font.family'] = 'Malgun Gothic'
plt.rcParams['axes.unicode_minus'] = False

# 페이지 설정
st.set_page_config(page_title="OTT 콘텐츠 분석 대시보드", layout="wide")

# DB 연결
password = quote_plus("1234")

@st.cache_resource
def get_engine():
    return create_engine(f'postgresql://postgres:{password}@localhost:5432/ott_analysis')

engine = get_engine()

# 타이틀
st.title("🎬 OTT 콘텐츠 노출 전략 분석 대시보드")
st.markdown("MovieLens 25M 데이터 기반 분석")
st.markdown("---")

# KPI 카드
col1, col2, col3, col4 = st.columns(4)
col1.metric("총 영화 수", "62,423개")
col2.metric("총 평점 수", "25,000,095개")
col3.metric("총 유저 수", "162,541명")
col4.metric("30일 재방문율", "35%")
st.markdown("---")

# 장르별 평균 평점
st.subheader("📊 장르별 평균 평점 Top 10")

@st.cache_data
def load_genre_data():
    query = text("""
        SELECT TRIM(genre) AS 장르,
               COUNT(*) AS 평점수,
               ROUND(AVG(r.rating)::numeric, 2) AS 평균평점
        FROM movies m
        JOIN ratings r ON m.movie_id = r.movie_id
        CROSS JOIN UNNEST(STRING_TO_ARRAY(m.genres, '|')) AS genre
        GROUP BY TRIM(genre)
        HAVING COUNT(*) > 1000
        ORDER BY 평균평점 DESC
        LIMIT 10
    """)
    with engine.connect() as conn:
        return pd.read_sql(query, conn)

df_genre = load_genre_data()

fig, ax = plt.subplots(figsize=(10, 4))
ax.barh(df_genre['장르'], df_genre['평균평점'])
ax.set_xlabel('평균 평점')
ax.set_title('장르별 평균 평점 Top 10')
ax.invert_yaxis()
st.pyplot(fig)
st.markdown("---")

# 연도별 트렌드
st.subheader("📈 연도별 영화 개봉 수 & 평균 평점")

@st.cache_data
def load_yearly_data():
    query = text("""
        SELECT 
            SUBSTRING(m.title FROM '\((\d{4})\)') AS year,
            COUNT(DISTINCT m.movie_id) AS 개봉수,
            ROUND(AVG(r.rating)::numeric, 2) AS 평균평점
        FROM movies m
        JOIN ratings r ON m.movie_id = r.movie_id
        GROUP BY SUBSTRING(m.title FROM '\((\d{4})\)')
        HAVING COUNT(DISTINCT m.movie_id) >= 10
        ORDER BY year ASC
    """)
    with engine.connect() as conn:
        return pd.read_sql(query, conn)

df_yearly = load_yearly_data()
df_yearly = df_yearly.dropna()

fig2, ax1 = plt.subplots(figsize=(12, 4))
ax2 = ax1.twinx()
ax1.bar(df_yearly['year'], df_yearly['개봉수'], alpha=0.6, color='steelblue', label='개봉수')
ax2.plot(df_yearly['year'], df_yearly['평균평점'], color='red', linewidth=2, label='평균평점')
ax1.set_xlabel('연도')
ax1.set_ylabel('개봉 수', color='steelblue')
ax2.set_ylabel('평균 평점', color='red')
ax1.set_title('연도별 영화 개봉 수 & 평균 평점')
ax1.set_xticks(df_yearly['year'][::5])
ax1.tick_params(axis='x', rotation=45)
fig2.legend(loc='upper left')
st.pyplot(fig2)
st.markdown("---")

# 유저 세그먼트
st.subheader("👥 유저 세그먼트 분석")

@st.cache_data
def load_segment_data():
    query = text("""
        WITH 유저세그먼트 AS (
            SELECT
                user_id,
                COUNT(*) AS 평점수,
                ROUND(AVG(rating)::numeric, 2) AS 평균평점,
                CASE
                    WHEN COUNT(*) >= 200 THEN '코어 마니아'
                    WHEN COUNT(*) >= 50 THEN '일반 헤비유저'
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
        ORDER BY 평균평점수 DESC
    """)
    with engine.connect() as conn:
        return pd.read_sql(query, conn)

df_segment = load_segment_data()

col1, col2 = st.columns(2)

with col1:
    fig3, ax3 = plt.subplots(figsize=(6, 4))
    ax3.bar(df_segment['세그먼트'], df_segment['유저수'])
    ax3.set_title('세그먼트별 유저 수')
    ax3.set_ylabel('유저 수')
    st.pyplot(fig3)

with col2:
    fig4, ax4 = plt.subplots(figsize=(6, 4))
    ax4.bar(df_segment['세그먼트'], df_segment['평균평점'], color='orange')
    ax4.set_title('세그먼트별 평균 평점')
    ax4.set_ylabel('평균 평점')
    ax4.set_ylim(3.0, 4.2)
    st.pyplot(fig4)

st.markdown("---")
st.caption("데이터 출처: MovieLens 25M | 분석: 조성빈")