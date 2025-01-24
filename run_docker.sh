#!/bin/bash

# Function to get all service names dynamically from docker-compose.yml
get_service_names() {
    # Extract all service names from the docker-compose.yml file
    SERVICE_NAMES=$(grep 'container_name:' docker_run/docker-compose.yml | awk '{print $2}')
    echo "$SERVICE_NAMES"
}

# Function to start the service
start_service() {
    cd docker_run
    docker compose up -d || {
        echo "Failed to start containers."
        exit 1
    }
    # Get the current running container names
    cd ..
    SERVICE_NAMES=$(get_service_names)
    echo "Currently running containers: ${SERVICE_NAMES}"
}

# Function to stop the service
stop_service() {
    cd docker_run
    docker compose down
}

# Function to attach to a specific service using number selection
attach_service() {
    SERVICE_NAMES=($(get_service_names)) # Convert to array
    echo "Available services:"
    for i in "${!SERVICE_NAMES[@]}"; do
        echo "$((i + 1)). ${SERVICE_NAMES[i]}"
    done

    read -p "Enter the number of the service to attach: " SERVICE_INDEX
    SERVICE_NAME=${SERVICE_NAMES[$((SERVICE_INDEX - 1))]} # Get the service name based on user input

    if [ -z "$SERVICE_NAME" ]; then
        echo "Invalid selection."
        exit 1
    fi

    CONTAINER_ID=$(docker ps -qf "name=${SERVICE_NAME}")
    if [ -z "$CONTAINER_ID" ]; then
        echo "Failed to find running container for service: ${SERVICE_NAME}"
        exit 1
    fi
    docker exec -it "$CONTAINER_ID" bash
}

# Main script logic
case "$1" in
start)
    start_service
    ;;
stop)
    stop_service
    ;;
attach)
    attach_service
    ;;
*)
    echo "Usage: $0 {start|stop|attach}"
    exit 1
    ;;
esac
