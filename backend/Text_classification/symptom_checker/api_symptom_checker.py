import argparse
import json
import os
from typing import List, Dict, Any

import numpy as np
import xgboost as xgb
from sklearn.preprocessing import LabelEncoder


def load_artifacts(prefix: str):
    """Load the trained model artifacts."""
    model_path = f"{prefix}.json"
    labels_path = f"{prefix}.labels.npy"
    features_path = f"{prefix}.features.txt"

    if not (os.path.exists(model_path) and os.path.exists(labels_path) and os.path.exists(features_path)):
        raise FileNotFoundError(f"Missing artifacts. Expected: {model_path}, {labels_path}, {features_path}")

    model = xgb.XGBClassifier()
    model.load_model(model_path)

    label_encoder = LabelEncoder()
    classes = np.load(labels_path, allow_pickle=True)
    label_encoder.classes_ = classes

    with open(features_path, "r", encoding="utf-8") as f:
        feature_names = [line.strip() for line in f if line.strip()]

    return model, label_encoder, feature_names


def build_feature_vector(symptom_names: List[str], selected_symptoms: List[str]) -> np.ndarray:
    """Convert symptom list to feature vector."""
    features = np.zeros(len(symptom_names), dtype=float)
    name_to_index = {name.lower().strip(): idx for idx, name in enumerate(symptom_names)}
    
    for symptom in selected_symptoms:
        key = symptom.lower().strip()
        if key in name_to_index:
            features[name_to_index[key]] = 1.0
    
    return features.reshape(1, -1)


def predict_symptoms_json(symptoms: List[str], model, label_encoder, feature_names: List[str]) -> Dict[str, Any]:
    """Return predictions in JSON format for API integration."""
    if not symptoms:
        return {"error": "No symptoms provided"}
    
    # Build feature vector
    x = build_feature_vector(feature_names, symptoms)
    
    # Get predictions
    proba = model.predict_proba(x)[0]
    top3_idx = np.argsort(proba)[-3:][::-1]
    
    # Format results
    predictions = []
    for rank, idx in enumerate(top3_idx, 1):
        disease_name = label_encoder.inverse_transform([idx])[0]
        confidence = float(proba[idx])
        predictions.append({
            "rank": rank,
            "disease": disease_name,
            "confidence": confidence,
            "confidence_percent": round(confidence * 100, 2)
        })
    
    return {
        "input_symptoms": symptoms,
        "primary_diagnosis": predictions[0],
        "top_predictions": predictions,
        "model_confidence": "high" if predictions[0]["confidence"] > 0.7 else "medium" if predictions[0]["confidence"] > 0.4 else "low"
    }


def predict_symptoms_csv(symptoms: List[str], model, label_encoder, feature_names: List[str]) -> str:
    """Return predictions in CSV format."""
    if not symptoms:
        return "error,No symptoms provided"
    
    x = build_feature_vector(feature_names, symptoms)
    proba = model.predict_proba(x)[0]
    top3_idx = np.argsort(proba)[-3:][::-1]
    
    csv_lines = ["rank,disease,confidence,confidence_percent"]
    for rank, idx in enumerate(top3_idx, 1):
        disease_name = label_encoder.inverse_transform([idx])[0]
        confidence = proba[idx]
        csv_lines.append(f"{rank},{disease_name},{confidence:.4f},{confidence*100:.2f}")
    
    return "\n".join(csv_lines)


def predict_symptoms_simple(symptoms: List[str], model, label_encoder, feature_names: List[str]) -> str:
    """Return simple text format."""
    if not symptoms:
        return "Error: No symptoms provided"
    
    x = build_feature_vector(feature_names, symptoms)
    proba = model.predict_proba(x)[0]
    top1_idx = np.argmax(proba)
    
    disease_name = label_encoder.inverse_transform([top1_idx])[0]
    confidence = proba[top1_idx]
    
    return f"Diagnosis: {disease_name} (Confidence: {confidence*100:.1f}%)"


def main():
    parser = argparse.ArgumentParser(description="API-style symptom checker using saved model")
    parser.add_argument("--symptoms", nargs="+", required=True, help="List of symptoms")
    parser.add_argument("--format", choices=["json", "csv", "simple"], default="json", help="Output format")
    parser.add_argument("--artifacts-prefix", default="symptom_checker/symptom_model", help="Path to model artifacts")
    args = parser.parse_args()

    try:
        # Load the trained model
        model, label_encoder, feature_names = load_artifacts(args.artifacts_prefix)
        
        # Get predictions in requested format
        if args.format == "json":
            result = predict_symptoms_json(args.symptoms, model, label_encoder, feature_names)
            print(json.dumps(result, indent=2))
        elif args.format == "csv":
            result = predict_symptoms_csv(args.symptoms, model, label_encoder, feature_names)
            print(result)
        elif args.format == "simple":
            result = predict_symptoms_simple(args.symptoms, model, label_encoder, feature_names)
            print(result)
            
    except Exception as e:
        error_result = {"error": str(e), "input_symptoms": args.symptoms}
        if args.format == "json":
            print(json.dumps(error_result, indent=2))
        else:
            print(f"Error: {e}")


if __name__ == "__main__":
    main()
