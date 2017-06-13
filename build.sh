#!/bin/bash

IMGPREFIX=bwv988
IMGNAME=zeppelin
IMG="${IMGPREFIX}/${IMGNAME}"

echo -e "Building docker image ${IMG}..."

docker build -t $IMG .
