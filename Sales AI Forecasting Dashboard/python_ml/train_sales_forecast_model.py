import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, r2_score
import joblib

# Load sample sales data
df = pd.read_csv("../data/sales_sample.csv", parse_dates=["Date"])

# Create simple time features
df["Year"] = df["Date"].dt.year
df["Month"] = df["Date"].dt.month
df["Quarter"] = df["Date"].dt.quarter
df["DayOfWeek"] = df["Date"].dt.dayofweek

# Features and target
target = "Revenue"
features = [
    "Region",
    "Category",
    "Product",
    "Units",
    "Price",
    "DiscountPct",
    "Year",
    "Month",
    "Quarter",
    "DayOfWeek",
]

X = df[features]
y = df[target]

cat_cols = ["Region", "Category", "Product"]
num_cols = [c for c in features if c not in cat_cols]

pre = ColumnTransformer(
    transformers=[
        ("cat", OneHotEncoder(handle_unknown="ignore"), cat_cols),
        ("num", StandardScaler(), num_cols),
    ]
)

model = Pipeline(steps=[
    ("preprocess", pre),
    ("regressor", RandomForestRegressor(
        n_estimators=200,
        random_state=42,
        n_jobs=-1
    ))
])

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

model.fit(X_train, y_train)
pred = model.predict(X_test)

print("MAE:", round(mean_absolute_error(y_test, pred), 2))
print("R2:", round(r2_score(y_test, pred), 4))

joblib.dump(model, "sales_forecast_model.joblib")
print("Model saved as sales_forecast_model.joblib")
