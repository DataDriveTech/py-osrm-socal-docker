# syntax=docker/dockerfile:1
FROM python:3.11-slim-bookworm

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV DEBUG 0

# Install requirements
RUN apt-get update && apt install -y \
    --no-install-recommends \  
    git \
    build-essential \
    cmake \
    autoconf \
    libtool \
    zlib1g-dev \
    lsb-release \
    python3-venv \
    build-essential \
    pkg-config \
    libbz2-dev \
    libstxxl-dev \
    libstxxl1v5  \
    libxml2-dev \
    libzip-dev \
    libboost-all-dev \
    lua5.4 \
    liblua5.4-dev \
    libtbb-dev \
    libomp-dev \
    python3-dev \
    xlsx2csv \
    curl \
    wget && rm -rf /var/lib/apt/lists/* \
    && git clone --depth 1 --branch master https://github.com/Project-OSRM/osrm-backend.git && \
    cd osrm-backend && mkdir -p build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-Wno-array-bounds -Wno-uninitialized" -DBUILD_SHARED_LIBS=ON && \
    cmake --build . && cmake --build . --target install && cp -r /osrm-backend/profiles/* /opt/ && rm -rf /osrm-backend && \
    ldconfig && mkdir /osm && cd /osm && wget https://download.geofabrik.de/north-america/us/california/socal-latest.osm.pbf && \
    osrm-extract -p /opt/car.lua socal-latest.osm.pbf && \
    osrm-contract socal-latest.osrm && \
    osrm-datastore socal-latest.osrm