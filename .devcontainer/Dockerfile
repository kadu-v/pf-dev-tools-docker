################################################################################
# SPDX-License-Identifier: MIT
# SPDX-FileType: SOURCE
# SPDX-FileCopyrightText: (c) 2022, Marcus Andrade
################################################################################

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo
ENV NVIDIA_DRIVER_CAPABILITIES graphics



# Add i386 to enable the installation of multiarch binaries (x86-32)
RUN dpkg --add-architecture i386
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    bc                      \
    ca-certificates         \
    curl                    \
    expect                  \
    file                    \
    git                     \
    iputils-ping            \
    jq                      \
    less                    \
    lib32ncurses5-dev       \
    lib32z1                 \
    libc6:i386              \
    libfontconfig1          \
    libglib2.0-0            \
    liblzma-dev             \
    libncurses5:i386        \
    libqt5xml5              \
    libsm6                  \
    libsm6:i386             \
    libssl-dev              \
    libstdc++6:i386         \
    libtcmalloc-minimal4    \
    libxext6:i386           \
    libxft2:i386            \
    libxrender1             \
    libzmq3-dev             \
    locales                 \
    make                    \
    nano                    \
    net-tools               \
    openjdk-8-jdk           \
    pkg-config              \
    python3-pip             \
    rsync                   \
    sed                     \
    squashfs-tools          \
    sudo                    \
    tar                     \
    tcl                     \
    tree                    \
    udev                    \
    unixodbc-dev            \
    unzip                   \
    usbutils                \
    wget                    \
    xauth                   \
    xvfb                    \
    libxss1                 \
    xz-utils             && \
    rm -r /var/lib/apt/lists/*

# Clean Up
RUN	apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* 

# Add instalation scripts to an image
ADD scripts/QuartusLiteSetup-23.1std.0.991-linux.run .
ADD devices/cyclonev-23.1std.0.991.qdz .

# Install Quartus Lite
# --mode        unattended  : Disalble GUI
# --accept-eula 0           : Agree end user license
# --installdir /opt/inteFPGA: Set the installation directory
RUN chmod a+x ./QuartusLiteSetup-23.1std.0.991-linux.run \
    && ./QuartusLiteSetup-23.1std.0.991-linux.run --mode unattended --accept_eula 1 --installdir /opt/intelFPGA
ENV PATH $PATH:/opt/intelFPGA/quartus/bin

# Install pf-dev-tools
RUN pip install pf-dev-tools