import io
import time
import traceback
import logging

import numpy as np
import tensorflow as tf
from PIL import Image
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
import os
import gdown

from fastapi.middleware.cors import CORSMiddleware

logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')


# --- Application Metadata ---
# This information is used to auto-generate the API documentation (/docs).
app = FastAPI(
    title="Skin Condition Prediction API",
    description="An API that uses a deep learning model to predict common skin conditions from images. "
                "Upload an image to the /predict endpoint to get a classification.",
    version="1.0.0"
)
# prevent connection issues from Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# --- Configuration ---
MODEL_PATH = "skin_canser_model_v2.keras"
GDRIVE_FILE_ID = "1LMFuYrMCbaREm1rondVLuOUBSAmHFy-7"
TARGET_IMAGE_SIZE = (380, 380)
CLASS_NAMES = ['BCC', 'MEL', 'NV']
model = None


def download_model_from_gdrive():
    """Downloads the model from Google Drive if it doesn't exist locally."""
    if not os.path.exists(MODEL_PATH):
        logging.info(f"Model not found at {
                     MODEL_PATH}. Downloading from Google Drive...")
        try:
            url = f'https: //drive.google.com/uc?id={GDRIVE_FILE_ID}'
            gdown.download(url, MODEL_PATH, quiet=False)
            logging.info("Model downloaded successfully.")
        except Exception as e:
            logging.error(
                f"FATAL: Failed to download model from Google Drive. Error: {e}")
            traceback.print_exc()
            # If download fails, the app can't start.
            # In a real production system, you might want more robust error handling here.
            raise e
    else:
        logging.info("Model already exists locally. Skipping download.")


# --- FastAPI Lifespan Events ---

@app.on_event("startup")
async def load_model_on_startup():
    """
       Downloads the model if needed, then loads it into memory.
    """
    download_model_from_gdrive()

    global model
    try:
        logging.info(f"Attempting to load model from: {MODEL_PATH}")
        model = tf.keras.models.load_model(MODEL_PATH, compile=False)
        logging.info("Model loaded successfully.")
        model.summary(print_fn=logging.info)

        # --- Model Warm-up ---
        logging.info("Warming up the model...")
        dummy_input = np.zeros(
            (1, TARGET_IMAGE_SIZE[0], TARGET_IMAGE_SIZE[1], 3), dtype=np.float32)
        _ = model.predict(dummy_input)
        logging.info("Model warm-up complete.")

    except Exception as e:
        logging.error(
            f"FATAL: Could not load model on startup from {MODEL_PATH}")
        logging.error(f"Error details: {e}")
        traceback.print_exc()


# --- Helper Functions ---

def preprocess_image(image_bytes: bytes) -> np.ndarray:
    """
    Preprocesses the input image bytes to the format expected by the model.
    This includes resizing and normalization.

    Args:
        image_bytes: The raw bytes of the image file (e.g., JPG, PNG).

    Returns:
        A NumPy array ready to be fed into the model.

    Raises:
        ValueError: If the image cannot be processed.
    """
    try:
        # 1. Open image from bytes using Pillow.
        image = Image.open(io.BytesIO(image_bytes))

        # 2. Ensure image is in RGB mode.
        if image.mode != 'RGB':
            image = image.convert("RGB")
            logging.info(f"Image converted from {image.mode} to RGB.")

        # 3. CRITICAL STEP: Resize the image to the target size the model expects.
        #    This is the most important preprocessing step to match the training pipeline.
        logging.info(f"Resizing image to {TARGET_IMAGE_SIZE}")
        image = image.resize(TARGET_IMAGE_SIZE)

        # 4. Convert the Pillow image to a NumPy array. Values are now [0, 255].
        image_array = np.array(image)

        # 5. Normalize the pixel values to the [0, 1] range, matching the training process.
        image_array = image_array.astype(np.float32) / 255.0

        # 6. Add a batch dimension. The model expects (batch_size, height, width, channels).
        input_tensor = np.expand_dims(image_array, axis=0)
        logging.info(
            f"Final input tensor shape for model: {input_tensor.shape}")

        return input_tensor

    except Exception as e:
        logging.error(f"Image preprocessing failed: {e}")
        traceback.print_exc()
        raise ValueError(
            "Could not preprocess the image. It may be corrupt or in an unsupported format.") from e


# --- API Endpoints ---

@app.get("/", summary="Root Endpoint", include_in_schema=False)
async def read_root():
    """
    A simple welcome message to verify the API is running.
    """
    return {"message": "Welcome to the Skin Condition Prediction API. Use the /docs endpoint to see documentation."}


@app.post("/predict", summary="Predict Skin Condition")
async def predict(file: UploadFile = File(..., description="The image file to be classified.")):
    """
    Receives an image, preprocesses it, and returns the model's prediction.

    - **Input**: An image file (e.g., JPEG, PNG).
    - **Output**: A JSON object containing the predicted class, confidence score,
      and the probabilities for all classes.
    """
    if model is None:
        logging.error("Prediction endpoint called, but model is not loaded.")
        raise HTTPException(
            status_code=503,
            detail="Model is not available. Please check server logs."
        )

    logging.info(
        f"Received prediction request for file: {file.filename} ({file.content_type})")
    request_start_time = time.time()

    try:
        contents = await file.read()

        if not file.content_type or not file.content_type.startswith("image/"):
            logging.warning(
                f"Unsupported content type: {file.content_type}. Proceeding anyway.")

        # --- Core Logic: Preprocess -> Predict -> Post-process ---
        input_tensor = preprocess_image(contents)

        predict_start_time = time.time()
        predictions_output = model.predict(input_tensor, verbose=0)
        logging.info(
            f"Model prediction took {time.time() - predict_start_time: .4f} seconds.")

        probabilities = predictions_output[0]
        class_index = int(np.argmax(probabilities))
        predicted_class_name = CLASS_NAMES[class_index]
        confidence_score = float(np.max(probabilities))

        logging.info(
            f"Predicted Class: '{predicted_class_name}' with Confidence: {confidence_score: .4f}")

        response_data = {
            "predicted_class": predicted_class_name,
            "confidence": confidence_score,
            "all_probabilities": {name: float(prob) for name, prob in zip(CLASS_NAMES, probabilities)}
        }

        total_time = time.time() - request_start_time
        logging.info(
            f"Total request processing time: {total_time: .4f} seconds.")

        return JSONResponse(content=response_data)

    except ValueError as ve:
        logging.error(f"Processing error: {ve}")
        raise HTTPException(status_code=400, detail=str(ve))
    except Exception as e:
        logging.error(f"An unexpected error occurred: {e}")
        traceback.print_exc()
        raise HTTPException(
            status_code=500, detail="An internal server error occurred.")
