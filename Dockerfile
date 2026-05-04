# Stage 1: Builder
FROM python:3.14-slim AS builder

WORKDIR /app

# Install build dependencies if needed (psycopg2-binary doesn't need many build-deps, but sometimes it's better to be safe)
# However, psycopg2-binary is pre-compiled.
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: Final
FROM python:3.14-slim

# Copy installed packages from builder
COPY --from=builder /install /usr/local

WORKDIR /app

# Copy source code
COPY src/ /app/src/

# Create a non-root user
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')"

# Start command
CMD ["uvicorn", "src.app:app", "--host", "0.0.0.0", "--port", "8080"]
