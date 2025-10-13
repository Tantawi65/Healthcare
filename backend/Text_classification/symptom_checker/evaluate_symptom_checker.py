import argparse
import os
from typing import Tuple

import numpy as np
import pandas as pd
import xgboost as xgb
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix


def load_data(csv_path: str) -> pd.DataFrame:
    if not os.path.exists(csv_path):
        raise FileNotFoundError(f"CSV not found: {csv_path}")
    df = pd.read_csv(csv_path)
    if df.shape[1] < 2:
        raise ValueError("CSV must have at least 2 columns (target + features)")
    return df


def split_encode(df: pd.DataFrame, test_size: float, seed: int) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray, LabelEncoder, list]:
    target = df.columns[0]
    X = df.iloc[:, 1:]
    y = df[target]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=test_size, random_state=seed, stratify=y
    )

    label_encoder = LabelEncoder()
    y_train_enc = label_encoder.fit_transform(y_train)
    y_test_enc = label_encoder.transform(y_test)

    return X_train.values, X_test.values, y_train_enc, y_test_enc, label_encoder, X.columns.tolist()


def build_model(num_classes: int):
    common_kwargs = dict(
        objective="multi:softprob",
        num_class=num_classes,
        eval_metric="mlogloss",
        tree_method="hist",
        n_estimators=300,
        max_depth=6,
        learning_rate=0.05,
        subsample=0.8,
        colsample_bytree=0.8,
        random_state=42,
    )
    try:
        model = xgb.XGBClassifier(device="cuda", **common_kwargs)
    except TypeError:
        try:
            model = xgb.XGBClassifier(tree_method="gpu_hist", **{k: v for k, v in common_kwargs.items() if k != "tree_method"})
        except Exception:
            model = xgb.XGBClassifier(**common_kwargs)
    return model


def main():
    parser = argparse.ArgumentParser(description="Evaluate XGBoost Symptom Checker accuracy")
    parser.add_argument("--csv", required=True, help="Path to cleaned CSV (target + binary features)")
    parser.add_argument("--test-size", type=float, default=0.2, help="Test set fraction (default 0.2)")
    parser.add_argument("--seed", type=int, default=42, help="Random seed (default 42)")
    args = parser.parse_args()

    print("Loading data...")
    df = load_data(args.csv)
    print(f"Shape: {df.shape}")

    print("Splitting and encoding labels...")
    X_train, X_test, y_train, y_test, label_enc, feature_names = split_encode(df, args.test_size, args.seed)
    num_classes = len(np.unique(y_train))
    print(f"Classes: {num_classes}; Features: {len(feature_names)}")

    print("Training model...")
    model = build_model(num_classes)
    try:
        model.fit(X_train, y_train, eval_set=[(X_test, y_test)], verbose=50, early_stopping_rounds=30)
    except TypeError:
        model.fit(X_train, y_train, eval_set=[(X_test, y_test)], verbose=50)

    print("Evaluating...")
    y_proba = model.predict_proba(X_test)
    y_pred = np.argmax(y_proba, axis=1)

    acc = accuracy_score(y_test, y_pred)
    print(f"\nAccuracy: {acc:.4f} ({acc*100:.2f}%)")

    print("\nClassification report:")
    target_names = label_enc.inverse_transform(np.arange(num_classes))
    print(classification_report(y_test, y_pred, target_names=target_names, zero_division=0))

    print("Confusion matrix (rows=true, cols=pred):")
    cm = confusion_matrix(y_test, y_pred)
    print(cm)


if __name__ == "__main__":
    main()


