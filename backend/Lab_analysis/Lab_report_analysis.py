import base64
import os
from huggingface_hub import InferenceClient
from tkinter import Tk, filedialog

def select_image():
    
    root = Tk()
    root.withdraw() 
    file_path = filedialog.askopenfilename(
        title="Select a Lab Report Image",
        filetypes=[("Image Files", "*.jpg;*.jpeg;*.png;*.bmp;*.tiff;*.webp")]
    )
    return file_path


client = InferenceClient(
    provider="nebius",
    api_key=os.getenv("HUGGINGFACE_API_KEY", "your-api-key-here"),
)
img = select_image()

with open(img, "rb") as f:
    image_bytes = f.read()
    image_b64 = base64.b64encode(image_bytes).decode("utf-8")

prompt = """
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
"""

completion = client.chat.completions.create(
    model="google/gemma-3-27b-it",
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "text", "text": """
Analyze this lab report and give me a brief, structured summary.

Format your response as follows:

Summary: (2–3 sentences explaining what the report shows)
Key Findings: (3–5 bullet points with main abnormal or notable values)
Interpretation: (1–2 sentences explaining what the findings suggest)
Note: (One line disclaimer that it’s not medical advice)

Keep it short, clear, and professional — like a medical summary written for quick review.
"""},
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

print(completion.choices[0].message.content.strip())
