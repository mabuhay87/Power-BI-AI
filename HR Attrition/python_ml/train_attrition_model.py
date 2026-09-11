import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import roc_auc_score, classification_report
import joblib

df=pd.read_csv("../data/Employees.csv")
target="AttritionFlag"
features=["Age","CommuteMiles","Department","Gender","JobRole","JobSatisfaction","MonthlySalary","OvertimeFlag","PerformanceRating","TenureYears","TrainingHoursMonthly","YearsSincePromotion"]
X=df[features]; y=df[target]
cat=["Department","Gender","JobRole"]; num=[c for c in features if c not in cat]
pre=ColumnTransformer([("cat",OneHotEncoder(handle_unknown="ignore"),cat),("num",StandardScaler(),num)])
model=Pipeline([("preprocess",pre),("classifier",RandomForestClassifier(n_estimators=300,random_state=42,class_weight="balanced"))])
Xtr,Xte,ytr,yte=train_test_split(X,y,test_size=.2,random_state=42,stratify=y)
model.fit(Xtr,ytr)
prob=model.predict_proba(Xte)[:,1]
print("ROC AUC:",round(roc_auc_score(yte,prob),4))
print(classification_report(yte,(prob>=.5).astype(int)))
joblib.dump(model,"hr_attrition_model.joblib")
