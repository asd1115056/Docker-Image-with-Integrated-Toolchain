#!/bin/bash

# Define color codes
RED='\033[0;31m'    # Red
GREEN='\033[0;32m'  # Green
YELLOW='\033[0;33m' # Yellow
NC='\033[0m'        # No Color

# Define the mounting directory and original archive directory
MOUNT_DIR="/home/ctng/toolchains"
ORIGINAL_FILES_DIR="/opt/x-tools"
TOOL_CHAIN_NAME=$(basename "$ORIGINAL_FILES_DIR"/*)

# Check if the mounting directory exists
if [ ! -d "$MOUNT_DIR" ]; then
    echo -e "${RED}[FAIL] Error: The mount directory $MOUNT_DIR does not exist.${NC}"
    exit 1
fi

# Initialize the mounting directory if it is empty
if [ -z "$(ls -A $MOUNT_DIR)" ]; then
    sudo cp -R $ORIGINAL_FILES_DIR/* $MOUNT_DIR
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[INFO] Files have been copied to $MOUNT_DIR.${NC}"
        echo -e "${YELLOW}[INFO] Updating .bashrc to include the toolchain binaries in PATH.${NC}"
        echo "export PATH=/${MOUNT_DIR}/${TOOL_CHAIN_NAME}/bin:\$PATH" >>/home/ctng/.bashrc
    else
        echo -e "${RED}[FAIL] Error: Failed to copy files.${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}[INFO] The mounting directory already contains data.${NC}"
fi

# Other initialization logic (such as the need to set permissions, etc.) can be added here
mkdir -p workspace
echo -e "${GREEN}[INFO] Workspace directory created.${NC}"

# Execute the preset command of the container (provided by CMD)
exec "$@"
