# Docker-Image-with-Integrated-Toolchain

This repository provides a Docker-based solution for building cross-compilation toolchains using Crosstool-NG. 

## Getting Started

### Prerequisites

- Docker with Buildx enabled

### Repository Structure

- **Configuration Files**: Contains various Crosstool-NG configuration files.
  - Directory: `ctng_configs/`
  - Example configurations: `arm-unknown-linux-uclibcgnueabi.config`, `aarch64-unknown-linux-uclibc.config`

- **Build Script**: Script to build Docker images based on specified configurations.
  - Script: `Build_image.sh`
  - Supports `load` and `push` modes for Docker images.


### Local Build

Run the build script with a specified configuration:

```bash
./Build_image.sh -c arm-unknown-linux-uclibcgnueabi.config
```

And, the default image's name will be `local/ct-ng:<ctng config name >`

### Usage

The toolchain will in `/home/ctng/x-tools`. You can mount to host or just use it in container.

Docker Compose:

```ymal
```