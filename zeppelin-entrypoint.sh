#!/bin/bash
IP=$(ifconfig eth0 | grep 'inet addr' | awk -F: '{print $2}'| awk '{print $1}')
echo -e "\n[Zeppelin] IP: ${IP}\n\n"

# Configure Hadoop cluster settings.
/hadoop_config.sh

# FIXME: This is not a good solution.
/service_wait.sh

exec $ZEPPELIN_HOME/bin/zeppelin.sh
