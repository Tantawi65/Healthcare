from pydantic import BaseModel, Field
from typing import List, Optional, Any

class AnalysisRequest(BaseModel):
    """Request model for base64 image analysis"""
    image: str = Field(..., description="Base64 encoded image string")

class AnalysisResponse(BaseModel):
    """Response model for lab report analysis"""
    success: bool = Field(..., description="Whether the analysis was successful")
    filename: Optional[str] = Field(None, description="Original filename if uploaded via file")
    analysis: dict = Field(..., description="Analysis results")

class ParsedAnalysis(BaseModel):
    """Structured analysis result"""
    error: bool = Field(False, description="Whether an error occurred")
    summary: str = Field("", description="Summary of the lab report")
    key_findings: List[str] = Field(default_factory=list, description="Key findings from the report")
    interpretation: str = Field("", description="Medical interpretation")
    note: str = Field("", description="Disclaimer note")
    raw_response: str = Field("", description="Raw response from the AI model")
    message: Optional[str] = Field(None, description="Error message if any")

class HealthResponse(BaseModel):
    """Health check response"""
    status: str = Field(..., description="Service status")
    service: str = Field(..., description="Service name")