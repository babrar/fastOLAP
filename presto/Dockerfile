FROM ubuntu:16.04

ARG PRESTO_VERSION=0.221

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PRESTO_HOME=/opt/presto-server-$PRESTO_VERSION

RUN mkdir -p /var/presto/data

WORKDIR /opt

RUN apt-get update && apt-get install -y -q apt-utils python-minimal wget openjdk-8-jdk netcat uuid-runtime
RUN wget -qO- https://repo1.maven.org/maven2/com/facebook/presto/presto-server/$PRESTO_VERSION/presto-server-$PRESTO_VERSION.tar.gz | tar zvxf -

COPY config /opt/config/
# Import AWS credentials
ARG AWS_S3_ACCESS_KEY
ARG AWS_S3_SECRET_KEY
ARG AWS_S3_ENDPOINT

RUN sed -i "s~insert_aws_s3_access_key~$AWS_S3_ACCESS_KEY~g" /opt/config/presto/coordinator/etc/catalog/hive.properties
RUN sed -i "s~insert_aws_s3_secret_key~$AWS_S3_SECRET_KEY~g" /opt/config/presto/coordinator/etc/catalog/hive.properties
RUN sed -i "s~insert_aws_s3_endpoint~$AWS_S3_ENDPOINT~g"     /opt/config/presto/coordinator/etc/catalog/hive.properties

RUN sed -i "s~insert_aws_s3_access_key~$AWS_S3_ACCESS_KEY~g" /opt/config/presto/worker/etc/catalog/hive.properties
RUN sed -i "s~insert_aws_s3_secret_key~$AWS_S3_SECRET_KEY~g" /opt/config/presto/worker/etc/catalog/hive.properties
RUN sed -i "s~insert_aws_s3_endpoint~$AWS_S3_ENDPOINT~g"     /opt/config/presto/worker/etc/catalog/hive.properties

ARG INCLUDE_COORDINATOR_NODE_PROVIDED=true
ARG INCLUDE_WORKER_NODE_PROVIDED=false
# XOR on master/slave
RUN test "$INCLUDE_COORDINATOR_NODE_PROVIDED" != "$INCLUDE_WORKER_NODE_PROVIDED"

ENV INCLUDE_COORDINATOR_NODE_PROVIDED $INCLUDE_COORDINATOR_NODE_PROVIDED
ENV INCLUDE_WORKER_NODE_PROVIDED $INCLUDE_WORKER_NODE_PROVIDED

RUN wget -q https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/0.221/presto-cli-0.221-executable.jar -O $PRESTO_HOME/bin/presto
RUN chmod +x $PRESTO_HOME/bin/presto
# Inject uuid as node id for the coordinator and worker
RUN NODE_ID_COORDINATOR=`uuidgen` && sed -i "s/insert_node_id/$NODE_ID_COORDINATOR/g" /opt/config/presto/coordinator/etc/node.properties
RUN NODE_ID_WORKER=`uuidgen` && sed -i "s/insert_node_id/$NODE_ID_WORKER/g" /opt/config/presto/worker/etc/node.properties

COPY presto-entrypoint.sh /opt
RUN chmod +x /opt/presto-entrypoint.sh
# remove in prod. needed for presto cli only
RUN apt-get install -y -q less

EXPOSE 4443

ENV KEYSTORE_DIR=/opt/keystore
COPY keystore $KEYSTORE_DIR/

ENTRYPOINT ["/opt/presto-entrypoint.sh"]

