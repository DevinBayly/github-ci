# see https://docs.docker.com/docker-cloud/builds/advanced/
# using ARG in FROM requires min v17.05.0-ce

ARG DOCKER_DEPS_TAG=latest

FROM  qgis/qgis3-build-deps:${DOCKER_DEPS_TAG} AS BUILDER
MAINTAINER Denis Rouzaud <denis@opengis.ch>

LABEL Description="Docker container with QGIS" Vendor="QGIS.org" Version="1.1"

# build timeout in seconds, so no timeout by default
ARG BUILD_TIMEOUT=360000

ARG CC=/usr/lib/ccache/gcc
ARG CXX=/usr/lib/ccache/g++
ENV LANG=C.UTF-8

#instead clone the repo to /QGIS
WORKDIR /
#RUN git clone https://github.com/qgis/QGIS.git
RUN apt install -y wget 
RUN wget "https://github.com/qgis/QGIS/archive/refs/tags/final-3_26_2.tar.gz" -O qgis.tar.gz
RUN tar xf qgis.tar.gz
# #COPY . /QGIS

# If this directory is changed, also adapt script.sh which copies the directory
# if ccache directory is not provided with the source
RUN mkdir -p /QGIS/.ccache_image_build
ENV CCACHE_DIR=/QGIS/.ccache_image_build
RUN ccache -M 1G
RUN ccache -s

RUN echo "ccache_dir: "$(du -h --max-depth=0 ${CCACHE_DIR})

WORKDIR /QGIS/build

RUN SUCCESS=OK \
  && cmake \
  -GNinja \
  -DUSE_CCACHE=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DWITH_DESKTOP=ON \
  -DWITH_SERVER=ON \
  -DWITH_3D=ON \
  -DWITH_BINDINGS=ON \
  -DWITH_CUSTOM_WIDGETS=ON \
  -DBINDINGS_GLOBAL_INSTALL=ON \
  -DWITH_STAGED_PLUGINS=ON \
  -DWITH_GRASS=ON \
  -DSUPPRESS_QT_WARNINGS=ON \
  -DDISABLE_DEPRECATED=ON \
  -DENABLE_TESTS=OFF \
  -DWITH_QSPATIALITE=ON \
  -DWITH_APIDOC=OFF \
  -DWITH_ASTYLE=OFF \
  -DQT5_3DEXTRA_LIBRARY="/usr/lib/x86_64-linux-gnu/libQt53DExtras.so" \
  -DQT5_3DEXTRA_INCLUDE_DIR="/QGIS/external/qt3dextra-headers" \
  -DQt53DExtras_DIR="/QGIS/external/qt3dextra-headers/cmake/Qt53DExtras" \
  -DCMAKE_PREFIX_PATH="/QGIS/external/qt3dextra-headers" \
  .. \
  && ninja install || SUCCESS=FAILED \
  && echo "$SUCCESS" > /QGIS/build_exit_value

# # Additional run-time dependencies
# RUN pip3 install jinja2 pygments pexpect && apt install -y expect

# ################################################################################
# # Python testing environment setup

# # Add QGIS test runner
# COPY .docker/qgis_resources/test_runner/qgis_* /usr/bin/

# # Make all scripts executable
# RUN chmod +x /usr/bin/qgis_*

# # Add supervisor service configuration script
# COPY .docker/qgis_resources/supervisor/ /etc/supervisor

# # Python paths are for
# # - kartoza images (compiled)
# # - deb installed
# # - built from git
# # needed to find PyQt wrapper provided by QGIS
# ENV PYTHONPATH=/usr/share/qgis/python/:/usr/share/qgis/python/plugins:/usr/lib/python3/dist-packages/qgis:/usr/share/qgis/python/qgis

# WORKDIR /

# # Run supervisor
# CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

# # Sara's singularity code
# # Bootstrap: docker
# # FROM: ubuntu:22.04

# # %post
# #   . /environment
# #   SHELL=/bin/bash
# #   apt-get update
# #   apt-get install -y wget gnupg software-properties-common
# #   DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true TZ=Etc/UTC apt-get -y install tzdata keyboard-configuration

# #   apt-get install -y wget git vim build-essential cmake libgtk2.0-0 python3 python3-dev python3-venv python3-distutils python3-apt libgtk-3-dev xauth curl firefox xvfb systemd python3-gdal binutils
# #   mkdir -m755 -p /etc/apt/keyrings
# #   wget -O /etc/apt/keyrings/qgis-archive-keyring.gpg https://download.qgis.org/downloads/qgis-archive-keyring.gpg

# #   echo "Types: deb deb-src" >> /etc/apt/sources.list.d/qgis.sources
# #   echo "URIs: https://qgis.org.debian" >> /etc/apt/sources.list.d/qgis.sources
# #   echo "Suites: jammy" >> /etc/apt/sources.list.d/qgis.sources
# #   echo "Architectures: amd64" >> /etc/apt/sources.list.d/qgis.sources
# #   echo "Components: main" >> /etc/apt/sources.list.d/qgis.sources
# #   echo "Signed-By: /etc/apt/keyrings/qgis-archive-keyring.gpg" >> /etc/apt/sources.list.d/qgis.sources
# #   apt update

# #   apt install -y qgis qgis-server grass qgis-plugin-grass saga libnetcdf-dev
# #   #git clone https://github.com/dtarb/TauDEM.git
# #   strip --remove-section=.node.ABI-tag /usr/lib/x86_64-linux-gnu/libQt5Core.so.5

# # %environment
# #   SHELL=/bin/bash