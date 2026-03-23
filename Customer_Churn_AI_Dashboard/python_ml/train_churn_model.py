import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import roc_auc_score, classification_report
import joblib

df = pd.read_csv("../data/FactCustomerChurn.csv")
target = "ChurnFlag"
features = [
    "Region", "CustomerSegment", "ContractType", "InternetService", "PaymentMethod",
    "TenureMonths", "MonthlyCharges", "SupportTickets90D", "LatePayments12M",
    "PaperlessBilling", "StreamingService", "TechSupport", "SeniorCitizen",
    "Dependents", "Partner"
]
X = df[features]
y = df[target]

cat_cols = ["Region", "CustomerSegment", "ContractType", "InternetService", "PaymentMethod"]
num_cols = [c for c in features if c not in cat_cols]

pre = ColumnTransformer(
    transformers=[
        ("cat", OneHotEncoder(handle_unknown="ignore"), cat_cols),
        ("num", StandardScaler(), num_cols),
    ]
)

model = Pipeline(steps=[
    ("preprocess", pre),
    ("classifier", LogisticRegression(max_iter=1000))
])

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)
model.fit(X_train, y_train)
pred_prob = model.predict_proba(X_test)[:, 1]
print("ROC AUC:", round(roc_auc_score(y_test, pred_prob), 4))
print(classification_report(y_test, (pred_prob >= 0.5).astype(int)))
joblib.dump(model, "churn_model.joblib")
