FROM python:3.11-slim

# Install nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY web/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY web/kernel_service.py .
COPY web/nginx.conf /etc/nginx/nginx.conf
COPY web/start.sh /app/start.sh

# Copy static files
COPY web/static/ /app/static/

# Create data directory and fix line endings
RUN mkdir -p /app/data && \
    sed -i 's/\r$//' /app/start.sh && \
    chmod +x /app/start.sh

# Expose port 80 (nginx)
EXPOSE 80

# Use the startup script
CMD ["/bin/bash", "/app/start.sh"]

