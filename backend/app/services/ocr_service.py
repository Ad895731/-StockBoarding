import pytesseract
from PIL import Image, ImageEnhance, ImageFilter
import os

class OCRService:
    @staticmethod
    def preprocess_image(image: Image.Image) -> Image.Image:
        """
        Preprocesses the image for better OCR accuracy:
        1. Converts to Grayscale (removes distracting background colors)
        2. Upscales for better character resolution
        3. Enhances contrast (makes text stand out against background)
        4. Applies slight sharpening
        """
        # 1. Convert to grayscale (L mode)
        gray = image.convert("L")

        # 2. Resize/upscale if the image is small (Tesseract likes > 300 DPI)
        width, height = gray.size
        if width < 1000 or height < 1000:
            gray = gray.resize((width * 2, height * 2), Image.Resampling.LANCZOS)

        # 3. Increase contrast
        enhancer = ImageEnhance.Contrast(gray)
        enhanced = enhancer.enhance(2.0)

        # 4. Sharpen edges
        sharpened = enhanced.filter(ImageFilter.SHARPEN)

        return sharpened

    @staticmethod
    def extract_text(image_path: str) -> str:
        """
        Reads an image file, preprocesses it, and extracts text using Tesseract OCR.
        """
        if not os.path.exists(image_path):
            raise FileNotFoundError(f"Image not found at {image_path}")

        try:
            original_image = Image.open(image_path)

            # Preprocess the image
            processed_image = OCRService.preprocess_image(original_image)

            # Tesseract config:
            # --psm 11: Sparse text. Finds as much text as possible in no particular order.
            # --oem 3: Default OCR Engine Mode (LSTM neural net).
            custom_config = r'--oem 3 --psm 11'
            raw_text = pytesseract.image_to_string(processed_image, config=custom_config)

            # Fallback: if psm 11 returns empty, try default psm 3
            if not raw_text.strip():
                raw_text = pytesseract.image_to_string(processed_image, config=r'--oem 3 --psm 3')

            return raw_text.strip()
        except Exception as e:
            print(f"Error during OCR extraction: {e}")
            raise e
