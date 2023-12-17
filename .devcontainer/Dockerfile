################################################################################
# SPDX-License-Identifier: MIT
# SPDX-FileType: SOURCE
# SPDX-FileCopyrightText: (c) 2022, Marcus Andrade
################################################################################

FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo
ENV NVIDIA_DRIVER_CAPABILITIES graphics



# Add i386 to enable the installation of multiarch binaries (x86-32)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    xserver-xorg \
    x11-apps \
    python3-pip \
    wget \
    locales \
    libtcmalloc-minimal4

# Clean Up
RUN	apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* 

# Add instalation scripts to an image
ADD patches/qenv.sh .
ADD ./download.sh .
RUN chmod u+x ./download.sh && ./download.sh

# Install Quartus Lite
# --mode        unattended  : Disalble GUI
# --accept-eula 0           : Agree end user license
# --installdir /opt/intelFPGA: Set the installation directory
RUN chmod a+x ./QuartusLiteSetup-23.1std.0.991-linux.run \
    && ./QuartusLiteSetup-23.1std.0.991-linux.run --mode unattended --accept_eula 1 --installdir /opt/intelFPGA
RUN patch /opt/intelFPGA/quartus/adm/qenv.sh ./diff/diff.patch 
ENV PATH $PATH:/opt/intelFPGA/quartus/bin
ENV LD_PRELOAD "/usr/lib/x86_64-linux-gnu/libstdc++.so.6  /usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4"

# Install pf-dev-tools
RUN pip install pf-dev-tools