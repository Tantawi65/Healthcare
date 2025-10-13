from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import base64
import io
from PIL import Image
from lab_analyzer import LabReportAnalyzer
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="Lab Report Analysis API",
    description="AI-powered lab report analysis service",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this properly for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize the lab analyzer
analyzer = LabReportAnalyzer()

@app.get("/")
async def root():
    """Health check endpoint"""
    return {"message": "Lab Report Analysis API is running"}

@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring"""
    return {"status": "healthy", "service": "lab-report-analyzer"}

@app.post("/analyze")
async def analyze_lab_report(file: UploadFile = File(...)):
    """
    Analyze a lab report image and return structured results
    
    Args:
        file: Uploaded image file (jpg, jpeg, png, bmp, tiff, webp)
    
    Returns:
        JSON response with analysis results
    """
    try:
        # Validate file type
        if not file.content_type.startswith('image/'):
            raise HTTPException(
                status_code=400, 
                detail="File must be an image (jpg, jpeg, png, bmp, tiff, webp)"
            )
        
        # Read and validate image
        contents = await file.read()
        if len(contents) == 0:
            raise HTTPException(status_code=400, detail="Empty file uploaded")
        
        # Validate image can be opened
        try:
            image = Image.open(io.BytesIO(contents))
            image.verify()  # Verify it's a valid image
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Invalid image file: {str(e)}")
        
        # Convert to base64 for analysis
        image_b64 = base64.b64encode(contents).decode("utf-8")
        
        # Analyze the lab report
        logger.info(f"Analyzing lab report: {file.filename}")
        analysis_result = await analyzer.analyze_report(image_b64)
        
        return JSONResponse(
            status_code=200,
            content={
                "success": True,
                "filename": file.filename,
                "analysis": analysis_result
            }
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error analyzing lab report: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@app.post("/analyze-base64")
async def analyze_lab_report_base64(data: dict):
    """
    Analyze a lab report from base64 encoded image
    
    Args:
        data: JSON with 'image' key containing base64 encoded image
    
    Returns:
        JSON response with analysis results
    """
    try:
        if 'image' not in data:
            raise HTTPException(status_code=400, detail="Missing 'image' field in request body")
        
        image_b64 = data['image']
        
        # Remove data:image/...;base64, prefix if present
        if image_b64.startswith('data:image'):
            image_b64 = image_b64.split(',')[1]
        
        # Validate base64 and image
        try:
            image_bytes = base64.b64decode(image_b64)
            image = Image.open(io.BytesIO(image_bytes))
            image.verify()
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Invalid base64 image: {str(e)}")
        
        # Analyze the lab report
        logger.info("Analyzing lab report from base64 data")
        analysis_result = await analyzer.analyze_report(image_b64)
        
        return JSONResponse(
            status_code=200,
            content={
                "success": True,
                "analysis": analysis_result
            }
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error analyzing base64 lab report: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

# Flutter-friendly endpoint aliases
@app.post("/api/analyze-lab")
async def analyze_lab_api(file: UploadFile = File(...)):
    """Flutter-friendly endpoint for lab analysis"""
    return await analyze_lab_report(file)

@app.post("/api/analyze-lab-base64")
async def analyze_lab_base64_api(data: dict):
    """Flutter-friendly endpoint for base64 lab analysis"""
    return await analyze_lab_report_base64(data)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)