# Personality Classification: Introvert vs. Extrovert

A machine learning project that accurately classifies individuals as Introverts or Extroverts based on their behavioral patterns and social habits. This project demonstrates a complete end-to-end ML pipeline, from data preprocessing and exploration to model deployment.


## 📊 Project Overview

The goal of this project was to build a robust classifier that can predict a person's personality type (Introvert or Extrovert) using a set of measurable features. The final model, a tuned CatBoost classifier, achieved **92.6% accuracy**, proving that machine learning can effectively discern between these personality traits based on behavior.

This project exemplifies key data science skills: data cleaning, exploratory analysis, feature engineering, model selection, hyperparameter tuning, and evaluation.

## 📁 Dataset

The dataset contains 2,900 entries with 7 features and 1 target variable.

**Features:**
*   `Time_spent_Alone`: Float (0-11)
*   `Stage_fear`: Categorical (Yes/No)
*   `Social_event_attendance`: Float (0-10)
*   `Going_outside`: Float (0-7)
*   `Drained_after_socializing`: Categorical (Yes/No)
*   `Friends_circle_size`: Float (0-15)
*   `Post_frequency`: Float (0-10)

**Target:**
*   `Personality`: Categorical (Introvert/Extrovert)

The dataset was well-balanced, with a nearly equal number of introvert and extrovert samples.

## 🛠️ Tech Stack & Libraries

*   **Language:** Python 3
*   **Data Handling:** Pandas, NumPy
*   **Visualization:** Matplotlib, Seaborn
*   **Machine Learning:** Scikit-Learn, XGBoost, CatBoost
*   **Model Deployment:** Pickle

## 🔧 Methodology & Workflow

1.  **Data Preprocessing:**
    *   Handled categorical features (`Stage_fear`, `Drained_after_socializing`) using One-Hot Encoding.
    *   Scaled numerical features using `StandardScaler`.
    *   Encoded the target variable (`Personality`) using Label Encoding.
    *   **Crucially, all preprocessing was done after train-test split to prevent data leakage.**

2.  **Model Training & Evaluation:**
    *   Trained and compared five different algorithms:
        *   Random Forest
        *   Support Vector Machine (SVM)
        *   AdaBoost
        *   XGBoost
        *   CatBoost
    *   Evaluated models based on **Accuracy** and **Weighted F1-Score**.

3.  **Hyperparameter Tuning:**
    *   Performed a `GridSearchCV` on the best-performing model (CatBoost) to optimize its parameters.
    *   Tuned parameters included: `iterations`, `learning_rate`, `depth`, and `l2_leaf_reg`.

## 📈 Results

The performance of all tested models was consistently high, with CatBoost and SVM slightly edging out the others.

| Model | Accuracy | Weighted F1-Score |
| :--- | :--- | :--- |
| **CatBoost (Tuned)** | **92.6%** | **92.6%** |
| SVM | 92.6% | 92.6% |
| Random Forest | 92.2% | 92.2% |
| XGBoost | 92.1% | 92.1% |
| AdaBoost | 91.6% | 91.6% |

**Key Insight:** The high performance across all tree-based and linear models indicates that the provided features are highly predictive of personality type, with minimal noise.

## 📬 Contact
Created by **Majid hasannejad**  
📧 Email: [majjidh7@outlook.com]  
🌐 GitHub: [https://github.com/majidh7]  
💼 LinkedIn: [https://www.linkedin.com/in/majidh7]


