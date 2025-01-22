FROM ubuntu:22.04

# Define build parameters
ARG CTNG_UID=1000
ARG CTNG_GID=1000
ARG CT_NG_CONFIG=default.config

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    PATH="/opt/ctng/bin:${PATH}"

# Install required tools and dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    gcc \
    g++ \
    gperf \
    bison \
    flex \
    texinfo \
    help2man \
    make \
    libncurses5-dev \
    python3-dev \
    autoconf \
    automake \
    libtool \
    libtool-bin \
    gawk \
    wget \
    bzip2 \
    xz-utils \
    unzip \
    patch \
    libstdc++6 \
    rsync \
    git \
    curl \
    jq \
    vim \
    nano \
    ca-certificates \
    --no-install-recommends && \
    apt-get -y autoremove --purge && \
    rm -rf /var/lib/apt/lists/*

# Download and install Crosstool-NG
WORKDIR /opt
RUN git clone https://github.com/crosstool-ng/crosstool-ng.git && \
    cd crosstool-ng && \
    ./bootstrap && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install && \
    rm -rf /opt/crosstool-ng

# Create work user
RUN groupadd -g ${CTNG_GID} ctng && \
    useradd -d /home/ctng -m -g ${CTNG_GID} -u ${CTNG_UID} -s /bin/bash ctng && \
    echo "ctng ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set working directory
WORKDIR /home/ctng

# Switch to normal user
USER ctng

# Copy configuration files
COPY ctng_configs /home/ctng/ctng_config

# Set up and build the toolchain
RUN mkdir -p /home/ctng/build_temp && \
    mkdir -p /home/ctng/src && \
    cp /home/ctng/ctng_config/${CT_NG_CONFIG} /home/ctng/build_temp/.config && \
    cd /home/ctng/build_temp && \
    ct-ng upgradeconfig && \
    ct-ng build -j$(nproc --ignore=1) && \
    rm -rf /home/ctng/src && \
    rm -rf /home/ctng/build_temp

# Update PATH to include the toolchain binaries
RUN echo "export PATH=/home/ctng/x-tools/${CT_NG_CONFIG%.config}/bin:\$PATH" >> /home/ctng/.bashrc

# Keep container running after build
CMD ["tail", "-f", "/dev/null"]
