FROM continuumio/miniconda3:latest

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
        jq \
        bash \
        findutils \
        coreutils \
        && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy kernel_indexer script from repo root
COPY kernel_indexer /usr/local/bin/kernel_indexer

# Make kernel_indexer executable
RUN chmod +x /usr/local/bin/kernel_indexer

# Copy entrypoint script from kernel-indexer directory
COPY kernel-indexer/entrypoint.sh /app/entrypoint.sh

# Fix line endings and make executable
RUN sed -i 's/\r$//' /app/entrypoint.sh && \
    chmod +x /app/entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]

