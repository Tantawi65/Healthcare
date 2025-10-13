import json
from huggingface_hub import InferenceClient
from typing import Dict, List, Optional

class SymptomAnalyzer:
    def __init__(self, api_token: str):
        """Initialize the SymptomAnalyzer with HuggingFace API token."""
        self.client = InferenceClient(token=api_token)
        self.model = "mistralai/Mistral-7B-Instruct-v0.1"  # You can change this to your preferred model
        
    async def analyze(self, symptoms_text: str) -> Dict:
        """
        Analyze the provided symptoms text and return structured analysis.
        
        Args:
            symptoms_text (str): Description of symptoms
            
        Returns:
            Dict containing potential conditions, recommendation, and urgency level
            
        Raises:
            ValueError: If the response cannot be parsed
            ConnectionError: If the API call fails
        """
        prompt = f"""You are an AI diagnostic assistant. Based on the following symptoms, 
        provide a structured analysis. Focus on being informative but cautious.
        
        Symptoms:
        {symptoms_text}
        
        Respond ONLY with a JSON object in this exact format:
        {{
            "potential_conditions": ["condition1", "condition2"],
            "recommendation": "brief medical advice",
            "urgency": "Low/Medium/High"
        }}
        
        Remember: This is for initial guidance only, not a final diagnosis."""
        
        try:
            response = await self.client.text_generation(
                prompt,
                model=self.model,
                max_new_tokens=500,
                temperature=0.3,
                return_full_text=False
            )
            
            return self._parse_response(response)
            
        except Exception as e:
            raise ConnectionError(f"Failed to get analysis: {str(e)}")
    
    def _parse_response(self, response: str) -> Dict:
        """
        Parse the LLM response into the required JSON structure.
        
        Args:
            response (str): Raw response from the LLM
            
        Returns:
            Dict with the parsed analysis
            
        Raises:
            ValueError: If response cannot be parsed into the required format
        """
        try:
            # Try to find JSON-like content in the response
            start_idx = response.find('{')
            end_idx = response.rfind('}') + 1
            if start_idx == -1 or end_idx == 0:
                raise ValueError("No JSON object found in response")
                
            json_str = response[start_idx:end_idx]
            parsed = json.loads(json_str)
            
            # Validate the required fields
            required_fields = ['potential_conditions', 'recommendation', 'urgency']
            if not all(field in parsed for field in required_fields):
                raise ValueError("Response missing required fields")
                
            # Validate urgency value
            if parsed['urgency'] not in ['Low', 'Medium', 'High']:
                raise ValueError("Invalid urgency value")
                
            # Ensure potential_conditions is a list
            if not isinstance(parsed['potential_conditions'], list):
                raise ValueError("potential_conditions must be a list")
                
            return parsed
            
        except json.JSONDecodeError as e:
            raise ValueError(f"Failed to parse response as JSON: {str(e)}")
            
        except Exception as e:
            raise ValueError(f"Error processing response: {str(e)}")

# Example usage:
# async def main():
#     analyzer = SymptomAnalyzer("your-hf-token-here")
#     result = await analyzer.analyze("Persistent headache for 3 days with sensitivity to light")
#     print(result)