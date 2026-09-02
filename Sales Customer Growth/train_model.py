# Portfolio demonstration script. Adjust paths before running.
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier, IsolationForest
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

INPUT_FILE = r"data/02_sales_customer_growth_data.xlsx"
OUTPUT_FILE = r"data/model_predictions_refresh.xlsx"

df = pd.read_excel(INPUT_FILE, sheet_name="CustomerPredictions")
X = df[['RecencyDays', 'OrderCount', 'LifetimeRevenue']].copy()
for col in X.select_dtypes(include="object").columns:
    X[col] = X[col].astype("category").cat.codes
y = df["ActualChurnFlag"]
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.25, random_state=42, stratify=y)
model = make_pipeline(StandardScaler(), LogisticRegression(max_iter=1000))
model.fit(X_train, y_train)
df["PredictionProbability"] = model.predict_proba(X)[:, 1]
df.to_excel(OUTPUT_FILE, index=False)
print(f"Saved {len(df):,} scored rows to {OUTPUT_FILE}")
