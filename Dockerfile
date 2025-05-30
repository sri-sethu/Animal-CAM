# Use a lightweight Python base image
FROM python:3.13-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install Git LFS, git, and necessary system packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    git-lfs \
    gcc \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev && \
    git lfs install && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Copy only dependency file first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies
RUN pip install --upgrade pip --root-user-action=ignore
RUN pip install --no-cache-dir --root-user-action=ignore -r requirements.txt

# Copy the rest of the application code
COPY . .

# Make sure LFS files are pulled
RUN git lfs track "*.psd"
RUN git lfs pull || echo "Git LFS pull failed (possibly not a git repo inside Docker build)"

# Expose port (optional)
EXPOSE 5000

# Start the app with Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "wsgi:app"]
