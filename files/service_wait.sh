#!/bin/bash
# Temporary script to wait for required service to be up and running.
# FIXME: This is not a good solution, need something better.

SERVICE_HOST=namenode
SERVICE_PORT=8020
SERVICE_TIMEOUT=20

echo "Waiting for $SERIVCE_HOST to start listening on $SERVICE_PORT..."
WAIT=0
while ! nc -z $SERVICE_HOST $SERVICE_PORT; do
  sleep 1
  WAIT=$(($WAIT + 1))
  if [ "$WAIT" -gt ${SERVICE_TIMEOUT} ]; then
    echo "Error: Timeout waiting for service to start."
    exit 1
  fi
done
