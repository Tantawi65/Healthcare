import requests
import base64
import json
from pathlib import Path

class LabReportAPIClient:
    """Client for testing the Lab Report Analysis API"""
    
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url.rstrip('/')
    
    def health_check(self):
        """Check if the API is running"""
        try:
            response = requests.get(f"{self.base_url}/health")
            return response.json()
        except requests.exceptions.RequestException as e:
            return {"error": f"Failed to connect: {str(e)}"}
    
    def analyze_image_file(self, image_path: str):
        """Analyze a lab report image file"""
        try:
            with open(image_path, 'rb') as f:
                files = {'file': (Path(image_path).name, f, 'image/jpeg')}
                response = requests.post(f"{self.base_url}/analyze", files=files)
            
            if response.status_code == 200:
                return response.json()
            else:
                return {
                    "error": True,
                    "status_code": response.status_code,
                    "message": response.text
                }
        except Exception as e:
            return {"error": f"Failed to analyze image: {str(e)}"}
    
    def analyze_base64_image(self, image_path: str):
        """Analyze a lab report using base64 encoding"""
        try:
            with open(image_path, 'rb') as f:
                image_b64 = base64.b64encode(f.read()).decode('utf-8')
            
            data = {"image": image_b64}
            response = requests.post(
                f"{self.base_url}/analyze-base64",
                json=data,
                headers={'Content-Type': 'application/json'}
            )
            
            if response.status_code == 200:
                return response.json()
            else:
                return {
                    "error": True,
                    "status_code": response.status_code,
                    "message": response.text
                }
        except Exception as e:
            return {"error": f"Failed to analyze base64 image: {str(e)}"}

def main():
    """Test the API client"""
    client = LabReportAPIClient()
    
    # Health check
    print("🏥 Testing Lab Report Analysis API")
    print("=" * 50)
    
    health = client.health_check()
    print(f"Health Check: {health}")
    print()
    
    # You can test with an actual image file
    # Uncomment and modify the path below to test with your lab report image
    
    # image_path = "your_lab_report_image.jpg"  # Replace with actual path
    # print(f"Analyzing image: {image_path}")
    # result = client.analyze_image_file(image_path)
    # print(json.dumps(result, indent=2))

if __name__ == "__main__":
    main()