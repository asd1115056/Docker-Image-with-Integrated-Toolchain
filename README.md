# Docker-Image-with-Integrated-Toolchain

This repository provides a Docker-based solution for building cross-compilation toolchains using Crosstool-NG.

## Getting Started

### Prerequisites

- Docker with Buildx enabled

### Repository Structure

- **Build**: Contains scripts and configurations for building Docker images.
  - Directory: `docker_build/`
  - Script: `Build_image.sh`
  - Configuration Files: `ctng_configs/`
    - Example configurations: `arm-unknown-linux-uclibcgnueabi.config`, `aarch64-unknown-linux-uclibc.config`

- **Run**: Contains scripts for running Docker images.
  - Directory: `docker_run/`
  - Script: `start_service.sh`
  - Docker Compose file: `docker-compose.yml`
  - Environment variables: `.env`

### Local Build

Run the build script with a specified configuration:

```bash
./docker_build/Build_image.sh -c arm-unknown-linux-uclibcgnueabi.config
```

The default image's name will be `local/ct-ng:<ctng config name>`

### Usage

To start the container, run:

```bash
./run_docker.sh
```