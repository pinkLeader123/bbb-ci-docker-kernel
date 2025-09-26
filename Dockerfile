FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /work

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libssl-dev \
    flex \
    bison \
    libelf-dev \
    libncurses-dev \
    python3 \
    bc \
    kmod \
    xz-utils \
    zstd \
    caca-utils \
    libgtk2.0-dev \
    libglib2.0-dev \
    libusb-1.0-0-dev \
    libnewt-dev \
    vim \
    ca-certificates \
    crossbuild-essential-armhf \
    && rm -rf /var/lib/apt/lists/*

# tạo user builder (tùy chọn)
RUN useradd -m builder
USER builder
ENV HOME=/home/builder
WORKDIR /work

CMD ["bash"]
