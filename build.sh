#!/bin/bash

IMGPREFIX=analytics
IMGNAME=docker-zeppelin
IMG="${IMGPREFIX}/${IMGNAME}"

echo -e "Building docker image ${IMG}..."

docker build -t $IMG .
