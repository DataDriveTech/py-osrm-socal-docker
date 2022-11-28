# syntax=docker/dockerfile:1
FROM python:3.10-slim-bullseye

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV DEBUG 0

# Install requirements
RUN apt-get update && apt install -y \  
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
    lua5.2 \
    liblua5.2-dev \
    libtbb-dev \
    libomp-dev \
    python3-dev \
    xlsx2csv \
    curl \
    wget && rm -rf /var/lib/apt/lists/*

# Clone the OSRM backend repository, compile, build, install libOSRM
RUN git clone --depth 1 --branch v5.26.0 https://github.com/Project-OSRM/osrm-backend.git && \
    cd osrm-backend && mkdir -p build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON && \
    cmake --build . && cmake --build . --target install && cp -r /osrm-backend/profiles/* /opt/ && rm -rf /osrm-backend

# Update ldconfig
RUN ldconfig

# Download Southern California Map

RUN mkdir /osm && cd /osm && wget https://download.geofabrik.de/north-america/us/california/socal-latest.osm.pbf && osrm-extract -p /opt/car.lua socal-latest.osm.pbf && osrm-partition socal-latest.osm.pbf && osrm-customize socal-latest.osm.pbf