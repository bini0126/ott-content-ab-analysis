import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

plt.rcParams['font.family'] = 'Malgun Gothic'  # Windows면 'Malgun Gothic'
plt.rcParams['axes.unicode_minus'] = False

df = pd.read_csv('./sql/movielens_cohort_retention.csv')

# 코호트를 연 단위로 묶기 (first_rating_month에서 연도만 추출)
df['cohort_year'] = pd.to_datetime(df['first_rating_month']).dt.year

# 연도별 * 경과월별로 active_users 합산
grouped = df.groupby(['cohort_year', 'months_since_first_rating'])['active_users'].sum().reset_index()

pivot = grouped.pivot(index='cohort_year', columns='months_since_first_rating', values='active_users')
month0 = pivot[0]
retention_pct = pivot.div(month0, axis=0) * 100

print(retention_pct.round(1))

fig, ax = plt.subplots(figsize=(10, 10))

heatmap = sns.heatmap(
    retention_pct,
    annot=True,
    fmt='.1f',
    cmap='YlGnBu',
    mask=retention_pct.isna(),
    linewidths=0.5,
    linecolor='white',
    ax=ax
)

ax.set_title('연도별 코호트 리텐션 매트릭스 (MovieLens 25M)', fontname='Malgun Gothic')
ax.set_xlabel('첫 평가 후 경과월', fontname='Malgun Gothic')
ax.set_ylabel('코호트 (첫 평가 연도)', fontname='Malgun Gothic')

# 컬러바 라벨은 따로 접근해서 폰트 지정
cbar = heatmap.collections[0].colorbar
cbar.set_label('잔존율 (%)', fontname='Malgun Gothic')

plt.tight_layout()
plt.savefig('./notebooks/movielens_cohort_retention_heatmap.png', dpi=150)
plt.show()