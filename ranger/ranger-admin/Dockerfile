FROM maven:3.5.4-jdk-8

LABEL version=1.0

ARG HADOOP_VERSION=2.7.7
ARG RANGER_VERSION=1.2.0

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV RANGER_HOME=/opt/ranger-${RANGER_VERSION}-admin
ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
ENV HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop

COPY ranger-entrypoint.sh /opt

RUN apt-get -q update && apt-get install -y -q python gcc wget bc libpostgresql-jdbc-java

RUN wget https://archive.apache.org/dist/ranger/${RANGER_VERSION}/apache-ranger-${RANGER_VERSION}.tar.gz -P /opt

WORKDIR /opt
# Ranger pulls hadoop configs only. Hadoop installation not required.
RUN mkdir -p $HADOOP_CONF_DIR
RUN tar zxvf apache-ranger-${RANGER_VERSION}.tar.gz

COPY config/ranger/pom.xml /opt/apache-ranger-${RANGER_VERSION}

RUN sed -i "s/insert_hadoop_version/$HADOOP_VERSION/g" /opt/apache-ranger-${RANGER_VERSION}/pom.xml

RUN cd /opt/apache-ranger-${RANGER_VERSION} \
 && export MAVEN_OPTS="-Xmx512M" \
 && mvn clean compile package assembly:assembly -DskipTests -U \
 && cp target/ranger-${RANGER_VERSION}-admin.tar.gz /opt

RUN tar zxvf ranger-${RANGER_VERSION}-admin.tar.gz \
 && chmod +x /opt/ranger-entrypoint.sh

COPY config/hadoop/core-site.xml config/hadoop/hadoop-env.sh config/hive/hive-site.xml ${HADOOP_CONF_DIR}/
COPY config/ranger/admin/install.properties config/ranger/admin/setup.sh ${RANGER_HOME}/

ARG RANGER_ADMIN_PASSWORD

RUN sed -i "s/insert_hadoop_conf_path/\/opt\/hadoop-$HADOOP_VERSION\/etc\/hadoop/g" ${RANGER_HOME}/install.properties
RUN sed -i "s/insert_ranger_admin_password/$RANGER_ADMIN_PASSWORD/g" ${RANGER_HOME}/install.properties
# Import AWS credentials
ARG AWS_S3_ACCESS_KEY
ARG AWS_S3_SECRET_KEY
ARG AWS_S3_BUCKET_URI
ARG AWS_S3_ENDPOINT

RUN sed -i "s~insert_s3_access_key~$AWS_S3_ACCESS_KEY~g" $HADOOP_CONF_DIR/core-site.xml
RUN sed -i "s~insert_s3_secret_key~$AWS_S3_SECRET_KEY~g" $HADOOP_CONF_DIR/core-site.xml
RUN sed -i "s~insert_s3_bucket_uri~$AWS_S3_BUCKET_URI~g" $HADOOP_CONF_DIR/core-site.xml
RUN sed -i "s~insert_s3_endpoint~$AWS_S3_ENDPOINT~g"     $HADOOP_CONF_DIR/core-site.xml
# Generate self-signed certs
RUN $JAVA_HOME/bin/keytool -keystore ranger.server.keystore.jks \
        -alias rangeradmin \
        -validity 3650 \
        -genkey \
        -noprompt \
        -dname "CN=Unknown, OU=Unknown, O=Unknown., L=Unknown, S=Unknown, C=Unknown" \
        -keyalg RSA \
        -storepass testpass_rename_me \
        -keypass testpass_rename_me \
        -keysize 4096 \ 
        -deststoretype pkcs12   
# Remove setup files
RUN rm -f *.tar.gz && rm -rf apache-ranger-${RANGER_VERSION}

EXPOSE 6182

ENTRYPOINT ["/opt/ranger-entrypoint.sh"]
