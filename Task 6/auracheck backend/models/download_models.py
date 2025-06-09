# download_models.py
import os
from deepface import DeepFace
import logging
from dotenv import load_dotenv
import numpy as np

# Load environment variables from .env file
load_dotenv()

# Ensure the directory exists
os.makedirs(os.environ.get("DEEPFACE_HOME", "/app/models"), exist_ok=True)

# Force DeepFace to use this directory
os.environ["DEEPFACE_HOME"] = os.environ.get("DEEPFACE_HOME", "/app/models")

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def download_models():
    """Download all required DeepFace models during build time"""
    logger.info("Starting pre-download of DeepFace models...")

    # Download face recognition model
    logger.info("Downloading VGG-Face model...")
    DeepFace.build_model("VGG-Face")

    # Force download of RetinaFace detector by making a sample verification
    logger.info("Downloading RetinaFace detector...")
    try:
        # Create a dummy sample image
        dummy_img = np.zeros((100, 100, 3), dtype=np.uint8)
        DeepFace.analyze(dummy_img, actions=['age', 'gender', 'emotion'],
                         enforce_detection=False,
                         detector_backend='retinaface')
        # Force DeepFace to download and initialize RetinaFace detector
        DeepFace.verify(
            dummy_img,
            dummy_img,
            model_name="VGG-Face",
            enforce_detection=False,
            detector_backend="retinaface"
        )
        logger.info("RetinaFace detector loaded successfully")
    except Exception as e:
        logger.warning(f"RetinaFace detector preload: {e}")

    logger.info("All models downloaded successfully!")

if __name__ == "__main__":
    download_models()