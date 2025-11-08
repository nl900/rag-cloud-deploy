FROM python:3.12-slim AS builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc && \
    rm -rf /var/lib/apt/lists/*

COPY app.py /app/

FROM python:3.12-slim AS runtime

# non-root user
RUN useradd -m -u 1001 appuser

WORKDIR /app

COPY --from=builder /app /app

RUN pip install --no-cache-dir fastapi uvicorn[standard] pydantic

USER appuser

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
