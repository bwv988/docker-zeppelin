#!/bin/bash

# Configure Hadoop cluster settings.
source /entrypoints/inject_hadoop_cfg.sh
source /entrypoints/inject_zeppelin_cfg.sh

# FIXME: This is not a good solution.
source /entrypoints/service_wait.sh

exec $ZEPPELIN_HOME/bin/zeppelin.sh
