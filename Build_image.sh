#!/bin/sh

# Default directory for configs
CONFIGS_DIR="./ctng_configs"

# Usage information
usage() {
    echo "Usage: $0 -c CONFIG_NAME"
    echo "  -c CONFIG_NAME   Specify the ct-ng config name (required)"
    echo "Example: $0 -c arm-unknown-linux-uclibcgnueabi.config"
    exit 1
}

# Parse arguments
while getopts "c:h" opt; do
    case "$opt" in
    c) CONFIG_NAME="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
    esac
done

# Ensure CONFIG_NAME is provided
if [ -z "$CONFIG_NAME" ]; then
    echo "Error: CONFIG_NAME is required."
    usage
fi

# Check if the config file exists
CONFIG_FILE="${CONFIGS_DIR}/${CONFIG_NAME}"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file '${CONFIG_NAME}' not found in '${CONFIGS_DIR}'."
    exit 1
fi

# Ensure Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker is not running. Please start the Docker daemon and try again."
    exit 1
fi

# Confirm the config to be used
echo "Using ct-ng config: ${CONFIG_FILE}"

# Ensure docker buildx is available
if ! docker buildx version >/dev/null 2>&1; then
    echo "Error: Docker Buildx is not available. Please ensure it is installed and configured."
    exit 1
fi

# Check if BuildKit instance already exists
if docker buildx inspect buildkit >/dev/null 2>&1; then
    echo "BuildKit instance 'buildkit' already exists, using existing instance."
    docker buildx use buildkit
else
    echo "Creating BuildKit instance with increased log size..."
    docker buildx create --bootstrap --use --name buildkit \
        --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=-1 \
        --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=-1
fi

# Set build action to load
DOCKER_BUILD_ACTION="--load"

# Run the build process with buildx
IMAGE_TAG="local/ct-ng:${CONFIG_NAME%.config}"
echo "Starting Docker build with config: $CONFIG_NAME in 'load' mode"
if docker buildx build --progress=plain --target final \
    --build-arg CT_NG_CONFIG="$CONFIG_NAME" \
    -t "$IMAGE_TAG" $DOCKER_BUILD_ACTION .; then
    echo "Docker image built successfully: $IMAGE_TAG"
    echo "Image loaded into local Docker daemon."
else
    echo "Error: Docker build failed!"
    exit 1
fi
