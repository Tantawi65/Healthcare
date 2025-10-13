import argparse
import os
import sys
import pandas as pd
import numpy as np


def standardize_columns(df: pd.DataFrame) -> pd.DataFrame:
    """Lowercase, strip, and replace spaces with underscores in column names."""
    df = df.copy()
    df.columns = [c.strip().lower().replace(" ", "_") for c in df.columns]
    return df


def drop_invalid_rows(df: pd.DataFrame) -> pd.DataFrame:
    """Drop rows with missing target (first column) and fully empty feature rows."""
    df = df.copy()
    target_col = df.columns[0]
    df = df[~df[target_col].isna()]
    feature_df = df.iloc[:, 1:]
    non_empty_mask = ~(feature_df.isna().all(axis=1) | (feature_df.sum(axis=1) == 0))
    df = df.loc[non_empty_mask]
    return df


def remove_constant_and_sparse_features(df: pd.DataFrame, min_positive_frac: float = 0.0005):
    """Remove columns that are constant or extremely sparse (near-zero variance)."""
    target = df.columns[0]
    X = df.iloc[:, 1:]
    keep_cols = []
    for col in X.columns:
        series = X[col]
        if series.nunique(dropna=True) <= 1:
            continue
        # If binary-like, compute positive ratio
        try:
            pos_frac = (series.fillna(0) > 0).mean()
        except Exception:
            pos_frac = 1.0
        if pos_frac < min_positive_frac:
            continue
        keep_cols.append(col)
    cleaned = pd.concat([df[[target]], X[keep_cols]], axis=1)
    return cleaned


def impute_missing(df: pd.DataFrame) -> pd.DataFrame:
    """Impute missing values in features with 0, keep target as is."""
    target = df.columns[0]
    X = df.iloc[:, 1:].fillna(0)
    return pd.concat([df[[target]], X], axis=1)


def limit_classes(df: pd.DataFrame, min_samples: int = 5) -> pd.DataFrame:
    """Keep only classes with at least min_samples samples."""
    target = df.columns[0]
    counts = df[target].value_counts()
    keep = counts[counts >= min_samples].index
    return df[df[target].isin(keep)]


def main():
    parser = argparse.ArgumentParser(description="Preprocess disease-symptom CSV for training.")
    parser.add_argument("--input", required=True, help="Path to raw CSV")
    parser.add_argument("--output", default="cleaned_dataset.csv", help="Path to save cleaned CSV")
    args = parser.parse_args()

    if not os.path.exists(args.input):
        print(f"❌ Input CSV not found: {args.input}")
        sys.exit(1)

    print("Loading CSV...")
    df = pd.read_csv(args.input)
    print(f"Raw shape: {df.shape}")

    print("Standardizing column names...")
    df = standardize_columns(df)

    print("Dropping invalid/empty rows...")
    df = drop_invalid_rows(df)
    print(f"After row cleanup: {df.shape}")

    print("Removing constant and sparse features...")
    df = remove_constant_and_sparse_features(df)
    print(f"After feature cleanup: {df.shape}")

    print("Imputing missing values (0 for symptoms)...")
    df = impute_missing(df)

    print("Limiting classes with very few samples...")
    df = limit_classes(df, min_samples=5)
    print(f"After class filtering: {df.shape}")

    print(f"Saving cleaned CSV to: {args.output}")
    df.to_csv(args.output, index=False)
    print("Done.")


if __name__ == "__main__":
    main()


