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
    - Example configurations: `arm-unknown-linux-uclibcgnueabi.config`, `aarch64-unknown-linux-uclibcgnueabi.config`

- **Run**: Contains scripts for running Docker images.
  - Directory: `docker_run/`
  - Script: `run_docker.sh`
  - Docker Compose file: `docker-compose.yml`
  - Environment variables: `.env`

### Local Build

Run the build script with a specified configuration:

```bash
./docker_build/Build_image.sh -c arm-unknown-linux-uclibcgnueabi.config
```

The default image's name will be `local/ct-ng:<ctng config name>`

### Usage

To manage the Docker containers, you can use the `run_docker.sh` script with the following commands:

- **Start the containers**:
  ```bash
  ./run_docker.sh start
  ```

- **Stop the containers**:
  ```bash
  ./run_docker.sh stop
  ```

- **Attach to a specific service**:
  ```bash
  ./run_docker.sh attach
  ```
  You will be prompted to select a service by number from the available services listed.

### Docker Compose Configuration

To use Docker Compose, you can define your services in the `docker-compose.yml` file located in the `docker_run/` directory. Here is an example configuration:

```yaml
version: '3.8'
services:
  arm-crosstool-ng:
    image: asd1115056/ct-ng:arm-unknown-linux-uclibcgnueabi
    #image: local/ct-ng:arm-unknown-linux-uclibcgnueabi #Use local build image
    container_name: arm-crosstool-ng
    tty: true
    environment:
      - CTNG_UID=1000
      - CTNG_GID=1000
      - TZ=Asia/Taipei
```

### Example

1. **Start all services**:
   ```bash
   ./run_docker.sh start
   ```

2. **Stop all services**:
   ```bash
   ./run_docker.sh stop
   ```

3. **Attach to a specific service**:
   ```bash
   ./run_docker.sh attach
   ```
   You will see a list of available services and can select one by entering its corresponding number.