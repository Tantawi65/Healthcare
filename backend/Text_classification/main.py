from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Dict, Any
import numpy as np
import xgboost as xgb
from sklearn.preprocessing import LabelEncoder
import os

# --- Model Loading and Prediction Logic ---

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

def get_predictions(symptoms: List[str], model, label_encoder, feature_names: List[str]) -> Dict[str, Any]:
    """Return predictions."""
    if not symptoms:
        return {"error": "No symptoms provided"}
    
    feature_vector = build_feature_vector(feature_names, symptoms)
    
    probabilities = model.predict_proba(feature_vector)[0]
    
    top_n = 5
    top_indices = probabilities.argsort()[-top_n:][::-1]
    
    predictions = [
        {
            "disease": label_encoder.inverse_transform([idx])[0],
            "probability": round(float(probabilities[idx]), 4),
        }
        for idx in top_indices
    ]
    
    return {"predictions": predictions}

# --- FastAPI App ---

app = FastAPI(
    title="Symptom Checker API",
    description="An API to predict diseases based on symptoms using an XGBoost model.",
    version="1.0.0",
)

# Add CORS middleware for Flutter integration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this properly for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load model and artifacts at startup
try:
    MODEL_ARTIFACTS_PREFIX = "symptom_model"
    model, label_encoder, feature_names = load_artifacts(MODEL_ARTIFACTS_PREFIX)
except FileNotFoundError as e:
    # This allows the app to start and show an error at the endpoint
    # if the model artifacts are not found.
    model, label_encoder, feature_names = None, None, None
    startup_error = str(e)
else:
    startup_error = None


class SymptomsRequest(BaseModel):
    symptoms: List[str]

@app.on_event("startup")
async def startup_event():
    # This is just to confirm startup logic has run.
    # The actual loading is done above.
    if startup_error:
        print(f"Startup Error: {startup_error}")
    else:
        print("Model and artifacts loaded successfully.")

@app.get("/")
def read_root():
    """A welcome message and basic API information."""
    return {"message": "Welcome to the Symptom Checker API. Go to /docs for usage information."}

@app.post("/predict", summary="Predict diseases from symptoms")
def predict(request: SymptomsRequest):
    """
    Predicts the top 5 most likely diseases based on a list of symptoms.

    - **symptoms**: A list of strings containing patient symptoms.
    """
    if startup_error:
        return {"error": f"Could not process request due to a startup error: {startup_error}"}
        
    predictions = get_predictions(request.symptoms, model, label_encoder, feature_names)
    return predictions

@app.get("/symptoms", summary="List all available symptoms")
def list_symptoms():
    """
    Returns a list of all available symptoms that the model was trained on.
    """
    if startup_error:
        return {"error": f"Could not retrieve symptoms due to a startup error: {startup_error}"}
    return {"symptoms": feature_names}

# Health check endpoint
@app.get("/health")
def health_check():
    """Health check endpoint for monitoring"""
    return {
        "status": "healthy", 
        "service": "symptom-checker",
        "model_loaded": startup_error is None
    }

# Flutter-friendly endpoints
@app.post("/api/check-symptoms", summary="Check symptoms - Flutter friendly")
def check_symptoms_api(request: SymptomsRequest):
    """
    Flutter-friendly endpoint to predict diseases from symptoms
    Returns consistent JSON format with confidence percentages
    """
    if startup_error:
        return {
            "success": False,
            "error": f"Could not process request due to a startup error: {startup_error}"
        }
    
    if not request.symptoms:
        return {
            "success": False,
            "error": "No symptoms provided"
        }
    
    # Get predictions using existing logic
    result = get_predictions(request.symptoms, model, label_encoder, feature_names)
    
    # Format for Flutter with confidence percentages and ranks
    if "error" in result:
        return {
            "success": False,
            "error": result["error"]
        }
    
    formatted_predictions = []
    for i, pred in enumerate(result["predictions"]):
        formatted_predictions.append({
            "rank": i + 1,
            "disease": pred["disease"],
            "confidence": pred["probability"],
            "confidence_percent": f"{pred['probability'] * 100:.2f}%"
        })
    
    return {
        "success": True,
        "predictions": formatted_predictions,
        "input_symptoms": request.symptoms
    }

@app.get("/api/symptoms", summary="Get available symptoms - Flutter friendly")
def get_symptoms_api():
    """
    Flutter-friendly endpoint to get all available symptoms
    """
    if startup_error:
        return {
            "success": False,
            "error": f"Could not retrieve symptoms due to a startup error: {startup_error}"
        }
    
    return {
        "success": True,
        "symptoms": feature_names,
        "total_symptoms": len(feature_names)
    }
