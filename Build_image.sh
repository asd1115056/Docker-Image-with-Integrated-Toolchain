#!/bin/sh

# Default directory for configs
CONFIGS_DIR="./ctng_configs"
BUILD_MODE="load" # Default to --load

# Usage information
usage() {
    echo "Usage: $0 -c CONFIG_NAME [-m MODE]"
    echo "  -c CONFIG_NAME   Specify the ct-ng config name (required)"
    echo "  -m MODE          Build mode: 'load' (default) or 'push'"
    echo "Example: $0 -c arm-unknown-linux-uclibcgnueabi.config -m push"
    exit 1
}

# Parse arguments
while getopts "c:m:h" opt; do
    case "$opt" in
    c) CONFIG_NAME="$OPTARG" ;;
    m) BUILD_MODE="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
    esac
done

# Ensure CONFIG_NAME is provided
if [ -z "$CONFIG_NAME" ]; then
    echo "Error: CONFIG_NAME is required."
    usage
fi

# Ensure BUILD_MODE is valid
if [ "$BUILD_MODE" != "load" ] && [ "$BUILD_MODE" != "push" ]; then
    echo "Error: Invalid mode '$BUILD_MODE'. Allowed values are 'load' or 'push'."
    usage
fi

# Check if the config file exists
CONFIG_FILE="${CONFIGS_DIR}/${CONFIG_NAME}"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file '${CONFIG_NAME}' not found in '${CONFIGS_DIR}'."
    exit 1
fi

# Confirm the config to be used
echo "Using ct-ng config: $CONFIG_FILE"

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

# Determine build action based on mode
DOCKER_BUILD_ACTION=""
if [ "$BUILD_MODE" = "load" ]; then
    DOCKER_BUILD_ACTION="--load"
elif [ "$BUILD_MODE" = "push" ]; then
    DOCKER_BUILD_ACTION="--push"
fi

# Make sure Docker Hub is able to login
if [ "$BUILD_MODE" = "push" ]; then
    echo "Checking Docker login..."
    if ! docker info | grep -q Username; then
        echo "Error: Not logged in to Docker Hub. Please log in before pushing."
        exit 1
    fi
fi

# Run the build process with buildx
echo "Starting Docker build with config: $CONFIG_NAME in '$BUILD_MODE' mode"
if docker buildx build --progress=plain \
    --build-arg CT_NG_CONFIG="$CONFIG_NAME" \
    -t ct-ng-"${CONFIG_NAME%.config}" $DOCKER_BUILD_ACTION .; then
    echo "Docker image built successfully: ct-ng-${CONFIG_NAME%.config}"
    if [ "$BUILD_MODE" = "load" ]; then
        echo "Image loaded into local Docker daemon."
    elif [ "$BUILD_MODE" = "push" ]; then
        echo "Image pushed to the remote registry."
    fi
else
    echo "Docker build failed!"
    exit 1
fi
