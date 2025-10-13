# Symptom Checker API - FastAPI Service for Flutter

A clean FastAPI-based symptom checker service designed for mobile app integration with AI-powered disease prediction.

## 🚀 Features

### Core Functionality

- **AI-Powered Disease Prediction**: XGBoost model for accurate symptom analysis
- **RESTful API**: Clean JSON endpoints for mobile integration
- **Confidence Scoring**: Ranked predictions with confidence percentages
- **Comprehensive Symptom Database**: Support for hundreds of medical symptoms

### Flutter Integration Ready

- **CORS Enabled**: Cross-origin requests supported for mobile apps
- **JSON Responses**: Consistent response format with error handling
- **Health Checks**: Service monitoring endpoints
- **File Upload Support**: Multi-part form data handling

## 🏗️ Architecture

```
symptom_checker/
├── main.py                    # FastAPI server with Flutter endpoints
├── api_symptom_checker.py     # Core API functions
├── symptom_checker.py         # Model training and core logic
├── evaluate_symptom_checker.py # Model evaluation
├── preprocess_data.py         # Data preprocessing utilities
├── symptom_model.json         # Trained XGBoost model
├── symptom_model.labels.npy   # Label encoder classes
├── symptom_model.features.txt # Feature names and order
└── requirements.txt           # Dependencies
```

## 🔧 Installation & Setup

### Prerequisites

- Python 3.13+ (recommended)
- FastAPI
- XGBoost
- Required packages (see requirements.txt)

### Quick Setup

1. **Navigate to project directory**:

   ```bash
   cd "Text_classification"
   ```

2. **Install dependencies**:

   ```bash
   pip install -r requirements.txt
   ```

3. **Start the FastAPI server**:

   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8002 --reload
   ```

4. **Verify service is running**:
   - Health check: http://localhost:8002/health
   - API documentation: http://localhost:8002/docs

## 🌐 API Endpoints

### Flutter Integration Endpoints

- **`GET /health`** - Health check and service status
- **`POST /api/check-symptoms`** - Main symptom analysis endpoint
- **`GET /api/symptoms`** - Get all available symptoms
- **`GET /docs`** - Interactive API documentation

### Legacy Support Endpoints

- **`POST /predict`** - Original prediction endpoint
- **`GET /symptoms`** - Original symptoms list endpoint

## 📱 Flutter Usage Examples

### Check Symptoms

```dart
final response = await http.post(
  Uri.parse('http://localhost:8002/api/check-symptoms'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'symptoms': ['fever', 'cough', 'headache']
  })
);

final result = jsonDecode(response.body);
// Returns: {"success": true, "predictions": [...], "input_symptoms": [...]}
```

### Get Available Symptoms

```dart
final response = await http.get(
  Uri.parse('http://localhost:8002/api/symptoms')
);

final result = jsonDecode(response.body);
// Returns: {"success": true, "symptoms": [...], "total_symptoms": 132}
```

## � Response Format

### Symptom Analysis Response

```json
{
  "success": true,
  "predictions": [
    {
      "rank": 1,
      "disease": "Common Cold",
      "confidence": 0.8547,
      "confidence_percent": "85.47%"
    },
    {
      "rank": 2,
      "disease": "Influenza",
      "confidence": 0.7234,
      "confidence_percent": "72.34%"
    }
  ],
  "input_symptoms": ["fever", "cough", "headache"]
}
```

### Available Symptoms Response

```json
{
  "success": true,
  "symptoms": ["fever", "cough", "headache", "nausea", "fatigue", "..."],
  "total_symptoms": 132
}
```

### Error Response

```json
{
  "success": false,
  "error": "No symptoms provided"
}
```

## �️ Development Features

### Model Components

- **XGBoost Classifier**: Pre-trained model for disease prediction
- **Label Encoder**: Maps disease indices to names
- **Feature Vector**: 132 symptom features for analysis
- **Confidence Scoring**: Probability-based ranking system

### CORS Configuration

Configured for Flutter mobile app integration:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## 🔒 Production Notes

For production deployment:

- Configure specific CORS origins instead of `*`
- Add rate limiting and authentication
- Use environment variables for configuration
- Monitor API usage and performance
- Implement proper logging and error tracking

---

## Original XGBoost Model Components

### Legacy Files

- `symptom_checker.py` — Train, save artifacts, evaluate, and interactive prediction
- `preprocess_data.py` — Clean the raw dataset into `cleaned_dataset.csv`
- `evaluate_symptom_checker.py` — Train/test split evaluation
- `main.py` — FastAPI backend service
- Model artifacts:
  - `symptom_model.json` — Trained XGBoost model
  - `symptom_model.labels.npy` — Label encoder classes
  - `symptom_model.features.txt` — Feature order used by the model

````

## Preprocess (optional)

```bash
python preprocess_data.py --input "Disease and symptoms dataset.csv" --output cleaned_dataset.csv
````

## Train and Save Artifacts (one-time)

```bash
python symptom_checker.py --csv cleaned_dataset.csv --save-prefix symptom_model
```

Creates:

- `symptom_model.json`
- `symptom_model.labels.npy`
- `symptom_model.features.txt`

## Evaluate Saved Model (no retraining)

```bash
python symptom_checker.py --eval-only --csv cleaned_dataset.csv --artifacts-prefix symptom_model
```

## Interactive Predictions (No Training Needed)

```bash
python symptom_checker.py --interactive-only --artifacts-prefix symptom_model
```

Enter symptoms separated by commas (e.g., `fever, cough, headache`). Type `list` to see features, or `quit` to exit.

## API-Style Predictions (Multiple Output Formats)

````bash
# JSON format (best for web apps/APIs)
python api_symptom_checker.py --symptoms fever cough headache --format json

## FastAPI Server
This project includes a FastAPI server to expose the symptom checker model as a web API.

### Running the API Server
1.  **Install all dependencies (including FastAPI and Uvicorn):**
    ```bash
    pip install -r requirements.txt
    ```

2.  **Start the server:**
    Run the following command in your terminal. The server will be accessible at `http://127.0.0.1:8000`.
    ```bash
    uvicorn main:app --reload
    ```

### API Endpoints
Once the server is running, you can access the interactive API documentation at `http://127.0.0.1:8000/docs`.

- **POST /predict**: Send a list of symptoms to get disease predictions.
  - **Example Request Body:**
    ```json
    {
      "symptoms": ["fever", "cough", "headache"]
    }
    ```

- **GET /symptoms**: Get a list of all valid symptoms the model recognizes.


# CSV format (best for data analysis)
python api_symptom_checker.py --symptoms fever cough headache --format csv

# Simple format (best for CLI)
python api_symptom_checker.py --symptoms fever cough headache --format simple
````

## Notes

- GPU is used automatically if supported by your XGBoost build; otherwise CPU.
- Keep the three artifact files together for evaluation and interactive use.
