FROM ubuntu:16.04

ARG HADOOP_VERSION=2.7.3
ARG HIVE_VERSION=2.1.0
# Import AWS credentials
ARG AWS_S3_ACCESS_KEY
ARG AWS_S3_SECRET_KEY
ARG AWS_S3_BUCKET_URI
ARG AWS_S3_ENDPOINT

WORKDIR /opt

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
ENV HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
ENV HIVE_HOME=/opt/apache-hive-${HIVE_VERSION}-bin

RUN apt-get update && apt-get install -y -q openjdk-8-jdk wget netcat-traditional libpostgresql-jdbc-java

RUN wget -qO- https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz | tar zvxf -
RUN wget -qO- https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zvxf -

COPY config/hive/hive-site.xml config/hive/hive-env.sh ${HIVE_HOME}/conf/
COPY config/hadoop/core-site.xml config/hadoop/hadoop-env.sh config/hive/hive-site.xml ${HADOOP_HOME}/etc/hadoop/

RUN ln -s /usr/share/java/postgresql-jdbc4.jar ${HIVE_HOME}/lib

RUN echo "export HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}" >> ${HIVE_HOME}/bin/hive-config.sh

RUN sed -i "s+insert_hadoop_home+$HADOOP_HOME+g"        ${HIVE_HOME}/conf/hive-env.sh && \
    sed -i "s+insert_hive_config_dir+$HIVE_HOME/conf+g" ${HIVE_HOME}/conf/hive-env.sh

ARG HIVE_USER_NAME
ARG HIVE_USER_PASSWORD

RUN sed -i "s/insert_hive_user_name/$HIVE_USER_NAME/g" ${HADOOP_HOME}/etc/hadoop/hive-site.xml && \
    sed -i "s/insert_hive_user_name/$HIVE_USER_NAME/g" ${HIVE_HOME}/conf/hive-site.xml

RUN sed -i "s/insert_hive_user_password/$HIVE_USER_PASSWORD/g" ${HADOOP_HOME}/etc/hadoop/hive-site.xml && \
    sed -i "s/insert_hive_user_password/$HIVE_USER_PASSWORD/g" ${HIVE_HOME}/conf/hive-site.xml

RUN sed -i "s~insert_s3_access_key~$AWS_S3_ACCESS_KEY~g" $HADOOP_CONF_DIR/core-site.xml && \
    sed -i "s~insert_s3_secret_key~$AWS_S3_SECRET_KEY~g" $HADOOP_CONF_DIR/core-site.xml && \
    sed -i "s~insert_s3_bucket_uri~$AWS_S3_BUCKET_URI~g" $HADOOP_CONF_DIR/core-site.xml && \
    sed -i "s~insert_s3_endpoint~$AWS_S3_ENDPOINT~g"     $HADOOP_CONF_DIR/core-site.xml

ARG HIVE_WAREHOUSE_FOLDER

RUN sed -i "s+insert_warehouse_folder+$HIVE_WAREHOUSE_FOLDER+g" ${HADOOP_HOME}/etc/hadoop/hive-site.xml && \
    sed -i "s+insert_warehouse_folder+$HIVE_WAREHOUSE_FOLDER+g" ${HIVE_HOME}/conf/hive-site.xml

RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME}

COPY hive-entrypoint.sh /opt
RUN chmod +x /opt/hive-entrypoint.sh 

USER hive
EXPOSE 9083

ENTRYPOINT ["/opt/hive-entrypoint.sh"]
