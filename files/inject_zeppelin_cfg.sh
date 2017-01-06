#!/bin/bash
export ZEPPELIN_HOME=/opt/zeppelin

# Look for SPARK config settings in the environment.
for c in `printenv | perl -sne 'print "$1 " if m/^ZEPPELIN_CONF_(.+?)=.*/'`; do
    name=`echo ${c} | perl -pe 's/___/-/g; s/__/_/g; s/_/./g'`
    var="ZEPPELIN_CONF_${c}"
    value=${!var}
    echo "Setting Zeppelin config property $name=$value"
    echo "export $name=$value" >> $ZEPPELIN_HOME/conf/zeppelin-env.sh
done
