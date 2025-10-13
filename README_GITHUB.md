# Healthcare App - AI-Powered Medical Analysis Platform

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)](https://fastapi.tiangolo.com)
[![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)](https://python.org)

A comprehensive healthcare application built with Flutter frontend and FastAPI backends, featuring AI-powered medical analysis tools including symptom checking, medical image classification, and lab report analysis.

## 🚀 Features

### 🔍 Symptom Checker
- **AI-Powered Disease Prediction**: XGBoost model for accurate symptom analysis
- **Interactive Symptom Selection**: Search and select from 132+ medical symptoms
- **Confidence Scoring**: Ranked disease predictions with confidence percentages
- **User-Friendly Interface**: Clean, intuitive symptom selection and results display

### 🖼️ Medical Image Classification
- **Cancer Detection**: TensorFlow EfficientNetV2S model for medical image analysis
- **Camera & Gallery Support**: Capture images directly or upload from gallery
- **Real-time Analysis**: Fast image processing with detailed confidence scores
- **Comprehensive Results**: Structured prediction results with medical insights

### 🧪 Lab Report Analysis
- **AI-Powered Lab Analysis**: Hugging Face inference for lab report interpretation
- **Document Upload**: Support for lab report images and documents
- **Structured Results**: Organized analysis with summary, key findings, and interpretations
- **Medical Insights**: Detailed explanations and recommendations

## 🏗️ Architecture

### Frontend (Flutter)
```
lib/
├── main.dart                          # App entry point
├── services/
│   └── api_service.dart              # API integration service
└── src/
    ├── config/
    │   ├── router.dart               # App navigation configuration
    │   └── theme.dart                # UI theme and styling
    ├── domain/
    │   └── models/                   # Data models for API responses
    │       ├── symptom_models.dart
    │       ├── image_classification_models.dart
    │       └── lab_analysis_models.dart
    └── presentation/
        └── screens/                  # UI screens
            ├── symptom_checker_screen.dart
            ├── image_uploader_screen.dart
            └── lab_analysis_screen.dart
```

### Backend Services
```
backend/
├── Text_classification/              # Symptom Checker API (Port 8002)
│   └── symptom_checker/
│       ├── main.py                   # FastAPI server
│       ├── api_symptom_checker.py    # API endpoints
│       └── symptom_checker.py        # XGBoost model logic
├── Image_classification/             # Image Classification API (Port 8000)
│   ├── main.py                       # FastAPI server
│   └── models/                       # TensorFlow models (excluded)
└── Lab_analysis/                     # Lab Analysis API (Port 8003)
    ├── main.py                       # FastAPI server
    └── lab_analyzer.py               # Hugging Face integration
```

## 🛠️ Installation & Setup

### Prerequisites
- **Flutter SDK**: 3.0+
- **Python**: 3.8+
- **Git**: Latest version

### Frontend Setup (Flutter)

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Tantawi65/Healthcare.git
   cd Healthcare
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the Flutter app**:
   ```bash
   flutter run
   ```

### Backend Setup (Python FastAPI)

#### 1. Symptom Checker Service

```bash
cd backend/Text_classification/symptom_checker

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start the server
uvicorn main:app --host 0.0.0.0 --port 8002 --reload
```

#### 2. Image Classification Service

```bash
cd backend/Image_classification

# Create virtual environment
python -m venv venv

# Activate virtual environment
venv\Scripts\activate  # Windows
# source venv/bin/activate  # macOS/Linux

# Install dependencies
pip install -r requirements.txt

# Start the server
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

#### 3. Lab Analysis Service

```bash
cd backend/Lab_analysis

# Create virtual environment
python -m venv venv

# Activate virtual environment
venv\Scripts\activate  # Windows
# source venv/bin/activate  # macOS/Linux

# Install dependencies
pip install -r requirements.txt

# Start the server
uvicorn main:app --host 0.0.0.0 --port 8003 --reload
```

## 📱 API Endpoints

### Symptom Checker API (Port 8002)
- `GET /health` - Health check
- `GET /api/symptoms` - Get all available symptoms
- `POST /api/check-symptoms` - Analyze symptoms and predict diseases

### Image Classification API (Port 8000)
- `GET /health` - Health check
- `POST /api/classify-image` - Upload and classify medical images

### Lab Analysis API (Port 8003)
- `GET /health` - Health check  
- `POST /api/analyze-lab` - Upload and analyze lab reports

## 🔧 Configuration

### API Configuration
Update the API base URLs in `lib/services/api_service.dart`:

```dart
class ApiService {
  static const String symptomCheckerBaseUrl = 'http://localhost:8002';
  static const String imageClassificationBaseUrl = 'http://localhost:8000';
  static const String labAnalysisBaseUrl = 'http://localhost:8003';
}
```

### Model Files
**⚠️ Important**: Model files are excluded from this repository due to size constraints. You'll need to:

1. **Train your own models** using the provided training scripts
2. **Download pre-trained models** from the appropriate sources
3. **Place model files** in the correct directories:
   - `backend/Text_classification/symptom_checker/symptom_model.*`
   - `backend/Image_classification/models/`
   - `backend/Lab_analysis/models/`

## 🧪 Testing

### Test API Endpoints

1. **Symptom Checker**:
   ```bash
   curl -X POST "http://localhost:8002/api/check-symptoms" \
        -H "Content-Type: application/json" \
        -d '{"symptoms": ["fever", "cough", "headache"]}'
   ```

2. **Image Classification**:
   ```bash
   curl -X POST "http://localhost:8000/api/classify-image" \
        -F "image=@/path/to/medical/image.jpg"
   ```

3. **Lab Analysis**:
   ```bash
   curl -X POST "http://localhost:8003/api/analyze-lab" \
        -F "image=@/path/to/lab/report.pdf"
   ```

## 🚀 Deployment

### Production Considerations

1. **Environment Variables**: Configure API URLs for production
2. **CORS Settings**: Update CORS origins for production domains
3. **Authentication**: Implement proper authentication and authorization
4. **Rate Limiting**: Add API rate limiting for production use
5. **Model Security**: Secure model files and API endpoints
6. **Database Integration**: Add database for user data and analysis history

### Docker Deployment (Optional)

Create Docker containers for each service:

```dockerfile
# Example Dockerfile for symptom checker
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
EXPOSE 8002

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8002"]
```

## 📊 Technology Stack

### Frontend
- **Flutter**: Cross-platform mobile development
- **Dart**: Programming language
- **HTTP Package**: API communication
- **Image Picker**: Camera and gallery access
- **Go Router**: Navigation management

### Backend
- **FastAPI**: Modern Python web framework
- **XGBoost**: Machine learning for symptom prediction
- **TensorFlow**: Deep learning for image classification
- **Hugging Face Transformers**: NLP for lab analysis
- **Uvicorn**: ASGI server

### AI/ML Models
- **Symptom Prediction**: XGBoost classifier trained on medical symptoms dataset
- **Image Classification**: EfficientNetV2S for medical image analysis
- **Lab Analysis**: Transformer models for document understanding

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This application is for educational and research purposes only. It should not be used as a substitute for professional medical advice, diagnosis, or treatment. Always consult with qualified healthcare professionals for medical concerns.

## 🎯 Future Enhancements

- [ ] User authentication and profiles
- [ ] Medical history tracking
- [ ] Integration with electronic health records
- [ ] Real-time chat with healthcare professionals
- [ ] Medication reminder system
- [ ] Appointment scheduling
- [ ] Offline mode support
- [ ] Multi-language support

## 📞 Support

For support, email your-email@example.com or join our Slack channel.

---

**Built with ❤️ for better healthcare accessibility**