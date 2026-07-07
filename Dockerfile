# Use a lightweight official Python image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set the working directory
WORKDIR /app

# Install system dependencies for cryptography / paramiko building if wheels are not available
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file first to leverage Docker build cache
COPY requirements.txt /app/

# Install python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code and documentation
COPY aegistrap /app/aegistrap
COPY config /app/config
COPY docs /app/docs
COPY scripts /app/scripts
COPY README.md /app/

# Create directories for data and logs
RUN mkdir -p /app/data /app/logs

# Expose ports:
# SSH (2222), FTP (2121), HTTP (8080), HTTPS (8443), Dashboard (5000)
EXPOSE 2222
EXPOSE 2121
EXPOSE 8080
EXPOSE 8443
EXPOSE 5000

# Run AegisTrap. --allow-public-dashboard permits the dashboard to be exposed outside the container.
CMD ["python", "-m", "aegistrap", "--allow-public-dashboard"]
