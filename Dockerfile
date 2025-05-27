# Use a lightweight Python image
FROM python:3.13-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install pip and system updates
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc curl && \
    pip install --upgrade pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# Set working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .

RUN pip install --upgrade pip
RUN pip install --no-cache-dir --timeout=100 --retries=10 --resume-retries=5 -r requirements.txt

# Copy app code
COPY . .

# Run Gunicorn server
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "wsgi:app"]
