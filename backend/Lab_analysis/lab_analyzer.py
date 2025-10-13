import base64
import os
from huggingface_hub import InferenceClient
import asyncio
from typing import Dict, Any
import logging

logger = logging.getLogger(__name__)

class LabReportAnalyzer:
    """Lab Report Analysis service using Hugging Face Inference Client"""
    
    def __init__(self):
        """Initialize the analyzer with Hugging Face client"""
        self.client = InferenceClient(
            provider="nebius",
            api_key=os.getenv("HUGGINGFACE_API_KEY", "your-api-key-here"),
        )
        self.model = "google/gemma-3-27b-it"
        
    async def analyze_report(self, image_b64: str) -> Dict[str, Any]:
        """
        Analyze a lab report image and return structured results
        
        Args:
            image_b64: Base64 encoded image string
            
        Returns:
            Dictionary containing structured analysis results
        """
        try:
            prompt = self._get_analysis_prompt()
            
            # Run the inference in a thread pool to avoid blocking
            loop = asyncio.get_event_loop()
            completion = await loop.run_in_executor(
                None, 
                self._run_inference, 
                image_b64, 
                prompt
            )
            
            # Extract and parse the response
            analysis_text = completion.choices[0].message.content.strip()
            
            # Parse the structured response
            parsed_result = self._parse_analysis_result(analysis_text)
            
            return parsed_result
            
        except Exception as e:
            logger.error(f"Error in analyze_report: {str(e)}")
            return {
                "error": True,
                "message": f"Analysis failed: {str(e)}",
                "raw_response": ""
            }
    
    def _run_inference(self, image_b64: str, prompt: str):
        """Run the Hugging Face inference synchronously"""
        return self.client.chat.completions.create(
            model=self.model,
            messages=[
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": prompt},
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{image_b64}"
                            }
                        }
                    ]
                }
            ],
        )
    
    def _get_analysis_prompt(self) -> str:
        """Get the structured analysis prompt"""
        return """
You are a medical analysis assistant.

Analyze the following lab report image and give a structured, professional summary
following these steps:

1. Extract the results (with normal ranges if available).
2. Highlight abnormal values clearly.
3. Explain what the results suggest in simple terms.
4. Provide an overall summary of health findings.
5. End with the disclaimer:
   "This analysis is for educational purposes only and should not replace professional medical advice."

If the image is unreadable, respond: "The image text is unclear."

Format your response as follows:

Summary: (2–3 sentences explaining what the report shows)
Key Findings: (3–5 bullet points with main abnormal or notable values)
Interpretation: (1–2 sentences explaining what the findings suggest)
Note: (One line disclaimer that it's not medical advice)

Keep it short, clear, and professional — like a medical summary written for quick review.
"""
    
    def _parse_analysis_result(self, analysis_text: str) -> Dict[str, Any]:
        """
        Parse the structured analysis result into a dictionary
        
        Args:
            analysis_text: Raw analysis text from the model
            
        Returns:
            Structured dictionary with parsed components
        """
        try:
            result = {
                "error": False,
                "summary": "",
                "key_findings": [],
                "interpretation": "",
                "note": "",
                "raw_response": analysis_text
            }
            
            # Check if image is unreadable
            if "The image text is unclear" in analysis_text:
                result["error"] = True
                result["message"] = "The image text is unclear or unreadable"
                return result
            
            lines = analysis_text.split('\n')
            current_section = None
            
            for line in lines:
                line = line.strip()
                if not line:
                    continue
                    
                # Identify sections
                if line.startswith('Summary:'):
                    current_section = 'summary'
                    result['summary'] = line.replace('Summary:', '').strip()
                elif line.startswith('Key Findings:'):
                    current_section = 'key_findings'
                elif line.startswith('Interpretation:'):
                    current_section = 'interpretation'
                    result['interpretation'] = line.replace('Interpretation:', '').strip()
                elif line.startswith('Note:'):
                    current_section = 'note'
                    result['note'] = line.replace('Note:', '').strip()
                else:
                    # Continue previous section
                    if current_section == 'summary' and not result['summary']:
                        result['summary'] = line
                    elif current_section == 'key_findings' and line.startswith(('•', '-', '*')):
                        result['key_findings'].append(line.lstrip('•-* '))
                    elif current_section == 'interpretation' and not result['interpretation']:
                        result['interpretation'] = line
                    elif current_section == 'note' and not result['note']:
                        result['note'] = line
            
            return result
            
        except Exception as e:
            logger.error(f"Error parsing analysis result: {str(e)}")
            return {
                "error": True,
                "message": f"Failed to parse analysis: {str(e)}",
                "raw_response": analysis_text
            }