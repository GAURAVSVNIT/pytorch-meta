FROM python:3.11-slim

LABEL org.opencontainers.image.title="Government Fraud Detection — OpenEnv"
LABEL org.opencontainers.image.description="AI agent training environment for government fraud detection"
LABEL org.opencontainers.image.version="1.0.0"
LABEL space_sdk="docker"
LABEL tags="openenv"

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies from the backend folder
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend application code
COPY backend/ ./backend/
# Copy metadata to root as well for spec discovery
COPY openenv.yaml .
COPY README.md .

WORKDIR /app/backend

# Expose port (HF Spaces uses 7860)
EXPOSE 7860

ENV PORT=7860
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:7860/health || exit 1

CMD ["python", "app.py"]
