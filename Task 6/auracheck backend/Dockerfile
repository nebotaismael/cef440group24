FROM python:3.12-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    DEEPFACE_HOME=/app/models \
    OMP_NUM_THREADS=1 \
    TF_FORCE_GPU_ALLOW_GROWTH=true \
    CUDA_VISIBLE_DEVICES=-1
# Install system dependencies for OpenCV
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    unzip \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Create necessary directories
RUN mkdir -p /app/models /app/app_temp

COPY requirements.txt .
COPY ./models/download_models.py .
COPY firebase.zip /app/
RUN unzip /app/firebase.zip firebase.json -d /app && \
    rm /app/firebase.zip
# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Download only essential models
RUN python download_models.py

COPY . .
RUN rm -rf ./models/* && rm download_models.py

# Ensure proper permissions
RUN chmod -R 755 /app/app_temp /app/models

EXPOSE 5000
# Reduced worker count and increased timeout
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "1", "--threads", "2", "--timeout", "120", "application:app"]

