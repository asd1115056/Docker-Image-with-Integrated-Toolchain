# Stage 1: Install dependencies
FROM ubuntu:22.04 AS base

# Define build arguments
ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    gcc g++ gperf bison flex texinfo help2man make \
    libncurses5-dev python3-dev autoconf automake \
    libtool libtool-bin gawk wget bzip2 xz-utils unzip \
    patch libstdc++6 rsync git curl jq vim nano \
    ca-certificates --no-install-recommends && \
    apt-get autoremove -y --purge && \
    rm -rf /var/lib/apt/lists/*

# Stage 2: Install Crosstool-NG and create user
FROM base AS ctng-install

# Define build arguments
ARG CTNG_UID=1000
ARG CTNG_GID=1000

# Set environment variables
ENV PATH="/usr/local/bin:$PATH"

# Create user and group for non-root builds
RUN groupadd -g ${CTNG_GID} ctng && \
    useradd -d /home/ctng -m -g ${CTNG_GID} -u ${CTNG_UID} -s /bin/bash ctng && \
    ls /home/ctng -al

# Clone and install Crosstool-NG
WORKDIR /opt

# Prepare patchs
COPY ctng_patchs ./ctng_patchs

# Clone the repository
RUN git clone https://github.com/crosstool-ng/crosstool-ng.git

# Copy patches to the cloned repository
RUN cp ctng_patchs/* crosstool-ng

# Set global git config
RUN cd crosstool-ng && \
    git config --global user.email "you@example.com" && \
    git config --global user.name "Your Name"

# Apply patches if they exist
RUN cd crosstool-ng && \
    if ls *.patch 1> /dev/null 2>&1; then \
    git am *.patch; \
    else \
    echo "No patch files found."; \
    fi

# Build and install Crosstool-NG
RUN cd crosstool-ng && \
    ./bootstrap && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install

# Clean up
RUN rm -rf /opt/crosstool-ng

# Stage 3: Compilation toolchain
FROM ctng-install AS toolchain-build

# Define build arguments
ARG CT_NG_CONFIG=default.config

# Set environment variables
ENV PATH="/usr/local/bin:$PATH"

# Switch to ctng user for non-root builds
USER ctng

# Prepare the build environment
WORKDIR /home/ctng
COPY ctng_configs ./ctng_config

# Compile the toolchain
RUN mkdir -p build_temp src && \
    cp ctng_config/${CT_NG_CONFIG} build_temp/.config && \
    cd build_temp && \
    ct-ng upgradeconfig && \
    ct-ng build -j$(nproc --ignore=1) && \
    ls -al /home/ctng/x-tools

# Clean up unnecessary files
RUN ls /home/ctng -al

# Stage 4: Final operating environment
FROM ubuntu:22.04 AS final

# Define build arguments
ARG CTNG_UID=1000
ARG CTNG_GID=1000
ARG CT_NG_CONFIG=default.config

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/home/ctng/x-tools/bin:$PATH"

# Install necessary packages for compilation and common tools
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    python3-pip \
    git \
    make \
    cmake \
    sudo \
    wget \
    curl \
    vim \
    nano \
    ca-certificates \
    net-tools \
    --no-install-recommends && \
    apt-get autoremove -y --purge && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create user and set permissions for the ctng user
RUN groupadd -g ${CTNG_GID} ctng && \
    useradd -d /home/ctng -m -g ${CTNG_GID} -u ${CTNG_UID} -s /bin/bash ctng && \
    echo "ctng ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chown -R ctng:ctng /home/ctng

# Switch to normal user
USER ctng

WORKDIR /home/ctng

# Copy the toolchain from the build stage
COPY --from=toolchain-build /home/ctng/x-tools /opt/x-tools

# Copy init.sh to the container
COPY init.sh init.sh

RUN sudo chmod +x init.sh

# Keep container running after build
CMD ["/bin/bash", "-c", "/home/ctng/init.sh && tail -f /dev/null"]
