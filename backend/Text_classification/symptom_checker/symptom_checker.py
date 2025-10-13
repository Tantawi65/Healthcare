import argparse
import os
from typing import List, Tuple

import numpy as np
import pandas as pd
import xgboost as xgb
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder


def load_dataset(csv_path: str) -> pd.DataFrame:
    if not os.path.exists(csv_path):
        raise FileNotFoundError(
            f"CSV not found at '{csv_path}'. Provide a valid path with --csv <path>."
        )
    data = pd.read_csv(csv_path)
    if data.shape[1] < 2:
        raise ValueError("Dataset must have at least 2 columns: target then feature columns.")
    return data


def train_model(data: pd.DataFrame):
    y = data.iloc[:, 0]

    # Remove diseases with only 1 record
    value_counts = y.value_counts()
    rare_diseases = value_counts[value_counts < 2].index
    data_filtered = data[~data.iloc[:, 0].isin(rare_diseases)]

    X = data_filtered.iloc[:, 1:]
    y = data_filtered.iloc[:, 0]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    label_encoder = LabelEncoder()
    y_train_encoded = label_encoder.fit_transform(y_train)
    y_test_encoded = label_encoder.transform(y_test)

    # Prefer GPU if available, but fall back to CPU if not supported
    common_kwargs = dict(
        objective="multi:softprob",
        num_class=len(np.unique(y_train_encoded)),
        eval_metric="mlogloss",
        tree_method="hist",
        n_estimators=400,
        max_depth=6,
        learning_rate=0.05,
        subsample=0.8,
        colsample_bytree=0.8,
        random_state=42,
    )

    try:
        model = xgb.XGBClassifier(device="cuda", **common_kwargs)
    except TypeError:
        # Older xgboost: no 'device' param. Try GPU via tree_method if supported, else CPU.
        try:
            model = xgb.XGBClassifier(tree_method="gpu_hist", **{k: v for k, v in common_kwargs.items() if k != "tree_method"})
        except Exception:
            model = xgb.XGBClassifier(**common_kwargs)

    try:
        model.fit(
            X_train,
            y_train_encoded,
            eval_set=[(X_test, y_test_encoded)],
            verbose=50,
            early_stopping_rounds=50,
        )
    except TypeError:
        # Older xgboost versions do not support early_stopping_rounds in sklearn API
        model.fit(
            X_train,
            y_train_encoded,
            eval_set=[(X_test, y_test_encoded)],
            verbose=50,
        )

    return model, label_encoder, X.columns.tolist()


def save_artifacts(model: xgb.XGBClassifier, label_encoder: LabelEncoder, feature_names: List[str], prefix: str) -> Tuple[str, str, str]:
    os.makedirs(os.path.dirname(prefix) or ".", exist_ok=True)
    model_path = f"{prefix}.json"
    labels_path = f"{prefix}.labels.npy"
    features_path = f"{prefix}.features.txt"

    try:
        model.save_model(model_path)
    except Exception:
        model.get_booster().save_model(model_path)

    # Save label encoder classes with allow_pickle=True since they contain strings
    np.save(labels_path, label_encoder.classes_, allow_pickle=True)

    with open(features_path, "w", encoding="utf-8") as f:
        for name in feature_names:
            f.write(f"{name}\n")

    return model_path, labels_path, features_path


def load_artifacts(prefix: str) -> Tuple[xgb.XGBClassifier, LabelEncoder, List[str]]:
    model_path = f"{prefix}.json"
    labels_path = f"{prefix}.labels.npy"
    features_path = f"{prefix}.features.txt"

    if not (os.path.exists(model_path) and os.path.exists(labels_path) and os.path.exists(features_path)):
        raise FileNotFoundError(
            f"Missing artifacts. Expected: '{model_path}', '{labels_path}', '{features_path}'."
        )

    model = xgb.XGBClassifier()
    model.load_model(model_path)

    label_encoder = LabelEncoder()
    # Load label encoder classes with allow_pickle=True since they contain strings
    classes = np.load(labels_path, allow_pickle=True)
    label_encoder.classes_ = classes

    with open(features_path, "r", encoding="utf-8") as f:
        feature_names = [line.strip() for line in f if line.strip()]

    return model, label_encoder, feature_names


def build_feature_vector(symptom_names: List[str], selected: List[str]) -> np.ndarray:
    features = np.zeros(len(symptom_names), dtype=float)
    name_to_index = {name.lower().strip(): idx for idx, name in enumerate(symptom_names)}
    for s in selected:
        key = s.lower().strip()
        if key in name_to_index:
            features[name_to_index[key]] = 1.0
    return features.reshape(1, -1)


def interactive_loop(model, label_encoder, symptom_names: List[str]):
    print("\n" + "=" * 60)
    print("🩺 Symptom Checker (XGBoost)")
    print("=" * 60)
    print("Enter symptoms separated by commas. Example: fever, cough, headache")
    print("Type 'list' to see all available symptoms, or 'quit' to exit.")
    print("=" * 60)

    while True:
        try:
            user = input("\n💬 Symptoms: ").strip()
            if user.lower() in {"quit", "exit", "q", ""}:
                print("👋 Goodbye!")
                break
            if user.lower() == "list":
                print("\nAvailable symptoms (features):")
                print(", ".join(symptom_names))
                continue

            selected = [s for s in user.split(",") if s.strip()]
            if not selected:
                print("⚠️  Please enter at least one symptom.")
                continue

            x = build_feature_vector(symptom_names, selected)
            proba = model.predict_proba(x)[0]
            top3_idx = np.argsort(proba)[-3:][::-1]
            top1 = top3_idx[0]

            top1_label = label_encoder.inverse_transform([top1])[0]
            top1_conf = proba[top1]

            print("\n📊 Prediction Results")
            print("-" * 60)
            print(f"🏥 Primary Diagnosis: {top1_label}")
            print(f"📈 Confidence: {top1_conf:.4f} ({top1_conf*100:.2f}%)")
            print("\n🏆 Top 3 Possible Conditions:")
            for rank, idx in enumerate(top3_idx, start=1):
                label = label_encoder.inverse_transform([idx])[0]
                print(f"  {rank}. {label}: {proba[idx]:.4f} ({proba[idx]*100:.2f}%)")

        except KeyboardInterrupt:
            print("\n👋 Interrupted. Goodbye!")
            break
        except Exception as e:
            print(f"❌ Error: {e}")


def main():
    parser = argparse.ArgumentParser(description="Symptom checker using an XGBoost classifier.")
    parser.add_argument(
        "--csv",
        type=str,
        required=False,
        help="Path to CSV dataset. First column must be target (disease), remaining columns symptoms.",
    )
    parser.add_argument(
        "--save-prefix",
        type=str,
        default=None,
        help="Prefix to save artifacts (creates .json/.labels.npy/.features.txt)",
    )
    parser.add_argument(
        "--eval-only",
        action="store_true",
        help="Evaluate previously saved artifacts on --csv and exit (no training).",
    )
    parser.add_argument(
        "--artifacts-prefix",
        type=str,
        default="symptom_checker/symptom_model",
        help="Prefix path to load artifacts (default: symptom_checker/symptom_model)",
    )
    parser.add_argument(
        "--interactive-only",
        action="store_true",
        help="Start interactive mode using saved artifacts only (no training).",
    )
    args = parser.parse_args()

    if args.interactive_only:
        try:
            model, label_encoder, feature_names = load_artifacts(args.artifacts_prefix)
        except FileNotFoundError as e:
            print(str(e))
            print("Train and save first, e.g.:\n  python symptom_checker/symtom_checker.py --csv cleaned_dataset.csv --save-prefix symptom_checker/symptom_model")
            return
        interactive_loop(model, label_encoder, feature_names)
        return

    if args.eval_only:
        if not args.csv:
            print("Provide CSV for evaluation. Example:\n  python symptom_checker/symtom_checker.py --eval-only --csv cleaned_dataset.csv --artifacts-prefix symptom_checker/symptom_model")
            return
        data = load_dataset(args.csv)
        try:
            model, label_encoder, feature_names = load_artifacts(args.artifacts_prefix)
        except FileNotFoundError as e:
            print(str(e))
            return
        target_col = data.columns[0]
        missing = [c for c in feature_names if c not in data.columns]
        if missing:
            print(f"CSV missing {len(missing)} feature columns from training. Example missing: {missing[:10]}")
            return
        X = data.loc[:, feature_names].fillna(0).values
        y = data[target_col].values
        y_enc = label_encoder.transform(y)
        proba = model.predict_proba(X)
        y_pred = np.argmax(proba, axis=1)
        acc = (y_pred == y_enc).mean()
        print(f"Accuracy on provided CSV: {acc:.4f} ({acc*100:.2f}%)")
        return

    if not args.csv:
        print("❗ No CSV provided. Run: python symptom_checker/symtom_checker.py --csv path/to/dataset.csv")
        return

    data = load_dataset(args.csv)
    print("Shape of dataset:", data.shape)
    model, label_encoder, symptom_names = train_model(data)

    if args.save_prefix:
        print("Saving artifacts...")
        paths = save_artifacts(model, label_encoder, symptom_names, args.save_prefix)
        for p in paths:
            print(f" - {p}")

    interactive_loop(model, label_encoder, symptom_names)


if __name__ == "__main__":
    main()

