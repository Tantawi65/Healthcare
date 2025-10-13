from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Dict, Any
import json
import numpy as np
import xgboost as xgb
import os
from pathlib import Path

# Initialize FastAPI app
app = FastAPI(
    title="Symptom Checker API",
    description="AI-powered symptom analysis for medical diagnosis",
    version="2.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request/Response models
class SymptomRequest(BaseModel):
    symptoms: List[str]

class PredictionResult(BaseModel):
    rank: int
    disease: str
    confidence: float
    confidence_percent: str

class SymptomResponse(BaseModel):
    success: bool
    predictions: List[PredictionResult] = []
    input_symptoms: List[str] = []
    error: str = None

class SymptomsListResponse(BaseModel):
    success: bool
    symptoms: List[str] = []
    total_symptoms: int = 0
    error: str = None

# Global variables for model components
model = None
feature_names = []
disease_labels = []

def load_model_components():
    """Load all model components at startup"""
    global model, feature_names, disease_labels
    
    try:
        # Get current directory
        current_dir = Path(__file__).parent
        
        # Load XGBoost model
        model_path = current_dir / "symptom_model.json"
        if not model_path.exists():
            raise FileNotFoundError(f"Model file not found: {model_path}")
        
        model = xgb.XGBClassifier()
        model.load_model(str(model_path))
        print(f"✅ Loaded XGBoost model from {model_path}")
        
        # Load feature names
        features_path = current_dir / "symptom_model.features.txt"
        if not features_path.exists():
            raise FileNotFoundError(f"Features file not found: {features_path}")
        
        with open(features_path, 'r') as f:
            feature_names = [line.strip() for line in f.readlines()]
        print(f"✅ Loaded {len(feature_names)} features")
        
        # Load disease labels - try different approaches
        labels_path = current_dir / "symptom_model.labels.npy"
        if not labels_path.exists():
            raise FileNotFoundError(f"Labels file not found: {labels_path}")
        
        # Try to load labels with different methods
        try:
            disease_labels = np.load(str(labels_path), allow_pickle=True)
            print(f"✅ Loaded {len(disease_labels)} disease labels")
        except Exception as e:
            print(f"❌ Failed to load labels with numpy: {e}")
            # Fallback: create generic labels based on model classes
            n_classes = model.n_classes_ if hasattr(model, 'n_classes_') else 10
            disease_labels = [f"Disease_{i}" for i in range(n_classes)]
            print(f"⚠️ Using fallback labels: {len(disease_labels)} generic disease names")
        
        return True
        
    except Exception as e:
        print(f"❌ Error loading model components: {e}")
        return False

def create_feature_vector(input_symptoms: List[str]) -> np.ndarray:
    """Create feature vector from input symptoms"""
    # Convert input symptoms to lowercase for matching
    input_symptoms_lower = [s.lower().strip() for s in input_symptoms]
    
    # Create binary vector
    feature_vector = np.zeros(len(feature_names))
    
    matched_symptoms = []
    for i, feature in enumerate(feature_names):
        feature_lower = feature.lower().strip()
        if feature_lower in input_symptoms_lower:
            feature_vector[i] = 1
            matched_symptoms.append(feature)
    
    print(f"Matched symptoms: {matched_symptoms}")
    return feature_vector.reshape(1, -1)

@app.on_event("startup")
async def startup_event():
    """Load model on startup"""
    success = load_model_components()
    if not success:
        print("❌ Failed to load model components!")
    else:
        print("🚀 Symptom Checker API ready!")

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "Symptom Checker API",
        "model_loaded": model is not None,
        "features_count": len(feature_names),
        "diseases_count": len(disease_labels)
    }

@app.get("/api/symptoms", response_model=SymptomsListResponse)
async def get_available_symptoms():
    """Get list of all available symptoms"""
    try:
        if not feature_names:
            raise HTTPException(status_code=500, detail="Model not loaded properly")
        
        return SymptomsListResponse(
            success=True,
            symptoms=feature_names,
            total_symptoms=len(feature_names)
        )
    
    except Exception as e:
        return SymptomsListResponse(
            success=False,
            error=str(e)
        )

@app.post("/api/check-symptoms", response_model=SymptomResponse)
async def check_symptoms(request: SymptomRequest):
    """Analyze symptoms and return disease predictions"""
    try:
        # Validate input
        if not request.symptoms:
            return SymptomResponse(
                success=False,
                error="No symptoms provided"
            )
        
        if model is None:
            return SymptomResponse(
                success=False,
                error="Model not loaded"
            )
        
        # Create feature vector
        feature_vector = create_feature_vector(request.symptoms)
        
        # Make prediction
        probabilities = model.predict_proba(feature_vector)[0]
        
        # Create predictions with confidence scores
        predictions = []
        for i, prob in enumerate(probabilities):
            if prob > 0.01:  # Only include predictions with >1% confidence
                disease_name = disease_labels[i] if i < len(disease_labels) else f"Disease_{i}"
                predictions.append({
                    "disease": str(disease_name),
                    "confidence": float(prob),
                    "confidence_percent": f"{prob * 100:.2f}%"
                })
        
        # Sort by confidence (highest first)
        predictions.sort(key=lambda x: x["confidence"], reverse=True)
        
        # Add rank and limit to top 5
        ranked_predictions = []
        for rank, pred in enumerate(predictions[:5], 1):
            ranked_predictions.append(PredictionResult(
                rank=rank,
                disease=pred["disease"],
                confidence=pred["confidence"],
                confidence_percent=pred["confidence_percent"]
            ))
        
        return SymptomResponse(
            success=True,
            predictions=ranked_predictions,
            input_symptoms=request.symptoms
        )
    
    except Exception as e:
        return SymptomResponse(
            success=False,
            error=f"Prediction error: {str(e)}"
        )

# Legacy endpoints for backward compatibility
@app.post("/predict")
async def legacy_predict(request: SymptomRequest):
    """Legacy predict endpoint"""
    response = await check_symptoms(request)
    if response.success:
        return {
            "predictions": [
                {
                    "disease": pred.disease,
                    "confidence": pred.confidence
                }
                for pred in response.predictions
            ]
        }
    else:
        raise HTTPException(status_code=400, detail=response.error)

@app.get("/symptoms")
async def legacy_symptoms():
    """Legacy symptoms endpoint"""
    response = await get_available_symptoms()
    if response.success:
        return {"symptoms": response.symptoms}
    else:
        raise HTTPException(status_code=500, detail=response.error)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8002)