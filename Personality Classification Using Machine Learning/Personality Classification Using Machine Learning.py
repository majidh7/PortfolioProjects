"""
Personality Classification Using Machine Learning

Description:
This project implements a machine learning pipeline to classify personality types
based on various features. It includes data preprocessing, multiple model comparisons,
and hyperparameter tuning for the best performing model.

Dataset: personality_dataset.csv
Target Variable: Personality
"""

# Environment Setup & Library Import
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pickle
from sklearn.metrics import classification_report, accuracy_score, f1_score, confusion_matrix
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.ensemble import RandomForestClassifier, AdaBoostClassifier
from sklearn.svm import SVC
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.impute import KNNImputer, SimpleImputer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import LabelEncoder
from sklearn.compose import ColumnTransformer
import xgboost as xgb
from catboost import CatBoostClassifier
import time

# Set random seed for reproducibility
RANDOM_STATE = 123
np.random.seed(RANDOM_STATE)

# Start timer
start_time = time.time()

# --- Data Loading & Initial Exploration ---
print("Loading data...")
data = pd.read_csv("personality_dataset.csv")
print(f"Dataset shape: {data.shape}")
print("\nFirst few rows:")
print(data.head().to_string())
print("\nDataset info:")
print(data.info())
print("\nMissing values per column:")
print(data.isnull().sum())
print("\nNumeric columns description:")
print(data.describe().to_string())
print("\nCategorical columns description:")
print(data.describe(exclude=np.number).to_string())

# --- Data Preprocessing ---
print("\nPreprocessing data...")

# Identify numeric and categorical columns
numeric_cols = data.select_dtypes(include=['float64', 'int64']).columns.tolist()
categorical_cols = data.select_dtypes(include=['object']).columns.tolist()

# Ensure target is not in feature lists
if 'Personality' in categorical_cols:
    categorical_cols.remove('Personality')
if 'Personality' in numeric_cols:
    numeric_cols.remove('Personality')

print(f"Numeric features: {numeric_cols}")
print(f"Categorical features: {categorical_cols}")

# Split data first to avoid data leakage
X = data.drop(columns=['Personality'])
y = data['Personality']

# Encode target variable
target_le = LabelEncoder()
y = target_le.fit_transform(y)

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=RANDOM_STATE, stratify=y
)

# Create preprocessing pipelines
numeric_transformer = Pipeline(steps=[
    ('imputer', KNNImputer(n_neighbors=5)),
    ('scaler', StandardScaler())
])

categorical_transformer = Pipeline(steps=[
    ('imputer', SimpleImputer(strategy='most_frequent')),
    ('encoder', OneHotEncoder(handle_unknown='ignore'))
])

# Combine preprocessing for numeric and categorical features
preprocessor = ColumnTransformer(
    transformers=[
        ('num', numeric_transformer, numeric_cols),
        ('cat', categorical_transformer, categorical_cols)
    ]
)

# Preprocess the data once
X_train_processed = preprocessor.fit_transform(X_train)
X_test_processed = preprocessor.transform(X_test)

# --- Model Training & Evaluation ---
print("\nTraining and evaluating models...")

# Define models dictionary (removed StandardScaler from SVM since data is already scaled)
models = {
    'Random Forest': RandomForestClassifier(n_estimators=100, random_state=RANDOM_STATE),
    'SVM': SVC(probability=True, random_state=RANDOM_STATE),
    'AdaBoost': AdaBoostClassifier(n_estimators=100, random_state=RANDOM_STATE),
    'XGBoost': xgb.XGBClassifier(random_state=RANDOM_STATE),
    'CatBoost': CatBoostClassifier(iterations=200, learning_rate=0.05, depth=6,
                                   eval_metric='Accuracy', verbose=0, random_state=RANDOM_STATE)
}

results = {}

for name, model in models.items():
    print(f"\nEvaluating {name}...")

    # Train model
    model.fit(X_train_processed, y_train)

    # Predict test data
    y_pred = model.predict(X_test_processed)

    # Calculate metrics
    accuracy = accuracy_score(y_test, y_pred)
    f1 = f1_score(y_test, y_pred, average='weighted')

    results[name] = {
        'model': model,
        'accuracy': accuracy,
        'f1_score': f1,
        'predictions': y_pred
    }

    # Print metrics and classification report
    print(f"Accuracy: {accuracy:.4f}")
    print(f"Weighted F1 Score: {f1:.4f}")
    print("Classification report:")
    print(classification_report(y_test, y_pred, zero_division=0))

# Select best model by weighted F1 score
best_f1 = -1
best_model_name = None
best_model = None

for model_name, result in results.items():
    if result['f1_score'] > best_f1:
        best_f1 = result['f1_score']
        best_model_name = model_name
        best_model = result['model']

print(f"\nBest model: {best_model_name} with weighted F1 score: {best_f1:.4f}")

# --- Hyperparameter Tuning for CatBoost ---
if best_model_name == 'CatBoost':
    print("\nPerforming hyperparameter tuning for CatBoost...")

    param_grid = {
        'iterations': [100, 200, 300],
        'learning_rate': [0.01, 0.05, 0.1],
        'depth': [4, 6, 8],
        'l2_leaf_reg': [1, 3, 5]
    }

    grid_search = GridSearchCV(
        estimator=CatBoostClassifier(verbose=0, random_state=RANDOM_STATE),
        param_grid=param_grid,
        scoring='f1_weighted',
        cv=3,
        n_jobs=-1,
        verbose=1
    )

    grid_search.fit(X_train_processed, y_train)

    best_model = grid_search.best_estimator_
    print(f"Best parameters: {grid_search.best_params_}")
    print(f"Best cross-validation F1 score: {grid_search.best_score_:.4f}")

    # Evaluate tuned model on test set
    y_pred = best_model.predict(X_test_processed)
    test_accuracy = accuracy_score(y_test, y_pred)
    test_f1 = f1_score(y_test, y_pred, average='weighted')
    print(f"Tuned model test accuracy: {test_accuracy:.4f}")
    print(f"Tuned model test weighted F1 score: {test_f1:.4f}")

# --- Save the Best Model ---
print("\nSaving the best model...")

# Create a full pipeline that includes the preprocessor and the best model
full_pipeline = Pipeline([
    ('preprocessor', preprocessor),
    ('classifier', best_model)
])

with open('best_personality_model.pkl', 'wb') as f:
    pickle.dump(full_pipeline, f)
print("Model saved successfully with pickle.")

# Confusion matrix for best model
y_pred_best = best_model.predict(X_test_processed)
cm = confusion_matrix(y_test, y_pred_best)

plt.figure(figsize=(8, 6))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues')
plt.title(f'Confusion Matrix for {best_model_name}')
plt.ylabel('True Label')
plt.xlabel('Predicted Label')
plt.tight_layout()
plt.savefig('confusion_matrix.png')
plt.show()

# --- End of Script ---
execution_time = time.time() - start_time
print(f"\nTotal execution time: {execution_time:.2f} seconds")