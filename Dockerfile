# syntax=docker/dockerfile:1
FROM python:3.12-slim-bookworm as builder

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV DEBUG 0

# Install requirements
RUN apt-get update && \
    apt-get -y --no-install-recommends install ca-certificates cmake make git gcc g++ libbz2-dev libxml2-dev wget \
    libzip-dev libboost1.81-all-dev lua5.4 liblua5.4-dev pkg-config wget -o APT::Install-Suggests=0 -o APT::Install-Recommends=0

RUN ldconfig /usr/local/lib && \
    git clone --branch v2021.12.0 --single-branch https://github.com/oneapi-src/oneTBB.git && \
    cd oneTBB && \
    mkdir build && \
    cd build && \
    cmake -DTBB_TEST=OFF -DCMAKE_BUILD_TYPE=Release ..  && \
    cmake --build . && \
    cmake --install .


RUN rm -rf /var/lib/apt/lists/* \
    && git clone --depth 1 --branch master https://github.com/Project-OSRM/osrm-backend.git && \
    cd osrm-backend && mkdir -p build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-Wno-array-bounds -Wno-uninitialized" -DBUILD_SHARED_LIBS=ON && \
    cmake --build . && cmake --build . --target install && cp -r /osrm-backend/profiles/* /opt/ && rm -rf /osrm-backend && \
    ldconfig && mkdir /osm && cd /osm && wget https://download.geofabrik.de/north-america/us/california/socal-latest.osm.pbf


# Multistage build to reduce image size
FROM python:3.12-slim-bookworm as runstage

COPY --from=builder /usr/local /usr/local
COPY --from=builder /opt /opt
COPY --from=builder /osm /osm

RUN apt-get update && \
    apt-get install -y --no-install-recommends libboost-program-options1.81.0 libboost-regex1.81.0 \
        libboost-date-time1.81.0 libboost-chrono1.81.0 libboost-filesystem1.81.0 \
        libboost-iostreams1.81.0 libboost-system1.81.0 libboost-thread1.81.0 \
        expat liblua5.4-0 && \
    rm -rf /var/lib/apt/lists/* && \
# add /usr/local/lib to ldconfig to allow loading libraries from there
    ldconfig /usr/local/lib

RUN cd /osm && \
    osrm-extract -p /opt/car.lua socal-latest.osm.pbf && \
    osrm-contract socal-latest.osrm && \
    osrm-datastore socal-latest.osrm