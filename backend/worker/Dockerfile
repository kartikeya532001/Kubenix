# syntax=docker/dockerfile:1.4
FROM python:3.10-slim

WORKDIR /app

# System deps for torch
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy worker
COPY worker.py .

CMD ["python", "worker.py"]
