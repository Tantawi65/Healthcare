import asyncio
import sys
import os

# Add current directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from lab_analyzer import LabReportAnalyzer

async def test_analyzer():
    """Test the analyzer with a dummy base64 string to see the response structure"""
    analyzer = LabReportAnalyzer()
    
    # Create a small dummy base64 image (1x1 white pixel PNG)
    dummy_image_b64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg=="
    
    print("Testing analyzer with dummy image...")
    try:
        result = await analyzer.analyze_report(dummy_image_b64)
        print("\nAnalysis result structure:")
        print("=" * 50)
        print(f"Result type: {type(result)}")
        print(f"Keys: {result.keys() if isinstance(result, dict) else 'Not a dict'}")
        print("\nFull result:")
        print(result)
        
        # Check if it has the expected structure
        if isinstance(result, dict):
            print("\nStructure analysis:")
            print(f"Has 'error' key: {'error' in result}")
            print(f"Has 'summary' key: {'summary' in result}")
            print(f"Has 'key_findings' key: {'key_findings' in result}")
            print(f"Has 'interpretation' key: {'interpretation' in result}")
            print(f"Has 'note' key: {'note' in result}")
            print(f"Has 'raw_response' key: {'raw_response' in result}")
            
    except Exception as e:
        print(f"Error testing analyzer: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(test_analyzer())