#!/bin/sh

# Set the service name (corresponding to the service name in docker-compose.yml)
SERVICE_NAME="arm-crosstool-ng"

docker compose down

# Start service
docker compose up -d || {
    echo "Failed to start container."
    exit 1
}

# Get container ID
CONTAINER_ID=$(docker ps -qf "name=${SERVICE_NAME}")
if [ -z "$CONTAINER_ID" ]; then
    echo "Failed to find running container for service: ${SERVICE_NAME}"
    exit 1
fi

# Enter container Bash
#docker exec -it "$CONTAINER_ID" bash
