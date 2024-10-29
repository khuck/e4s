#!/bin/bash -e

if [[ $# -ne 1 || ( "$1" != "base" && "$1" != "complete" ) ]] ; then
  echo "usage: $0 <base|complete>"
  exit 1
fi

BUILD_TYPE=$1

ONEAPI_VERSION=${ONEAPI_VERSION:-2025.0}
BUILD_DATE=$(printf '%(%Y.%m.%d)T' -1)
BUILD_TAG=${BUILD_TAG:-${BUILD_DATE}}
BUILD_NAME=ubuntu22.04-runner-amd64-oneapi-${ONEAPI_VERSION}
if [[ "$BUILD_TYPE" == "base" ]]; then
  BUILD_NAME=${BUILD_NAME}-base
fi

REGISTRY=${REGISTRY:-ecpe4s}
OUTPUT_IMAGE="${REGISTRY}/${BUILD_NAME}:${BUILD_TAG}"

docker build \
 --build-arg ONEAPI_VERSION=${ONEAPI_VERSION} \
 --target ${BUILD_TYPE} \
 -t "${OUTPUT_IMAGE}" \
 .
