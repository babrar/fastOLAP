#!/usr/bin/env bash

WAIT_COUNTER=0
MAX_RETRIES=20

until nc -z postgres-for-hive-metastore.docker-hive-net 5432
do
    sleep 15
    if [ $WAIT_COUNTER -ge $MAX_RETRIES ]
    then
	exit 1
    fi
    WAIT_COUNTER=$((WAIT_COUNTER+1))
    echo "Retry No $WAIT_COUNTER of $MAX_RETRIES"
done

# Hadoop paths
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE=$HADOOP_HOME/lib/native
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib"
export PATH=$PATH:$HADOOP_HOME/bin
export HADOOP_PID_DIR=$HADOOP_HOME/hadoop2_data/hdfs/pid
export HADOOP_OPTS="$HADOOP_OPTS -Dcom.amazonaws.services.s3.enableV4"

cd $HIVE_HOME
bin/schematool -dbType postgres -initSchema
bin/hive --service metastore
# keep the container running
tail -f /dev/null

