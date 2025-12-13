# py-osrm-docker
Python and OSRM C++ in one docker image + Southern California and Colorado Maps 

## Build

docker build -t py-osrm-socal .

## Publish

docker image tag py-osrm-socal sebmilardo/py-osrm-socal:25.03
docker image push sebmilardo/py-osrm-socal:25.03
