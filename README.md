# py-osrm-docker
Python and OSRM C++ in one docker image + Southern California Map 

## Build

docker build -t py-osrm-socal .

## Publish

docker image tag py-osrm-socal sebmilardo/py-osrm-socal:24.06
docker image push sebmilardo/py-osrm-socal:24.06