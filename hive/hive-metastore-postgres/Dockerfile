FROM postgres:9.6.14

ARG HIVE_USER_NAME
ARG HIVE_USER_PASSWORD
# Any scripts placed under /docker-entrypoint-initdb.d/ will be executed while setting up the container
RUN echo "CREATE USER $HIVE_USER_NAME WITH PASSWORD '$HIVE_USER_PASSWORD';"  > /docker-entrypoint-initdb.d/create_users.sql
RUN echo "CREATE DATABASE metastore;"                                       >> /docker-entrypoint-initdb.d/create_users.sql
RUN echo "GRANT ALL PRIVILEGES ON DATABASE metastore to  $HIVE_USER_NAME"   >> /docker-entrypoint-initdb.d/create_users.sql

EXPOSE 5432
