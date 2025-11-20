FROM python:3.11-slim

# Install nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY kernel_service.py .
COPY nginx.conf /etc/nginx/nginx.conf
COPY start.sh .

# Copy static files
COPY static/ /app/static/

# Create data directory
RUN mkdir -p /app/data && \
    chmod +x /app/start.sh

# Expose port 80 (nginx)
EXPOSE 80

# Use the startup script
CMD ["/app/start.sh"]

