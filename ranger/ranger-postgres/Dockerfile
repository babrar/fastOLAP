FROM postgres:10.3

ARG RANGER_ADMIN_PASSWORD

RUN echo "CREATE USER rangeradmin WITH PASSWORD '$RANGER_ADMIN_PASSWORD';" > /docker-entrypoint-initdb.d/create_users.sql
RUN echo "CREATE DATABASE ranger;"                                         >> /docker-entrypoint-initdb.d/create_users.sql 
RUN echo "GRANT ALL PRIVILEGES ON DATABASE ranger to rangeradmin;"         >> /docker-entrypoint-initdb.d/create_users.sql


