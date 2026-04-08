# Stage 1: Build the frontend dashboard
FROM node:20-slim AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ ./
RUN npm run build

# Stage 2: Build the final submission image
FROM python:3.11-slim

LABEL org.opencontainers.image.title="Government Fraud Detection — OpenEnv"
LABEL org.opencontainers.image.description="AI agent training environment for government fraud detection with investigator dashboard"
LABEL org.opencontainers.image.version="1.1.0"
LABEL space_sdk="docker"
LABEL tags="openenv"

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies
COPY backend/requirements.txt ./backend/
RUN pip install --no-cache-dir -r ./backend/requirements.txt

# Copy backend application code
COPY backend/ ./backend/
COPY openenv.yaml .
COPY README.md .

# Copy the built frontend into the backend's static directory
COPY --from=frontend-builder /app/frontend/out ./backend/static

WORKDIR /app

# Expose port (HF Spaces uses 7860)
EXPOSE 7860

ENV PORT=7860
ENV PYTHONUNBUFFERED=1

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:7860/health || exit 1

CMD ["python", "-m", "backend.app"]
