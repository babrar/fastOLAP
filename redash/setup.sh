#!/usr/bin/env bash
# This script setups dockerized Redash on Ubuntu 18.04.
set -eux

SCRIPT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd)
REDASH_BASE_PATH=$SCRIPT_DIR

create_directories() {
    if [[ ! -e $REDASH_BASE_PATH ]]; then
        # Useful if REDASH_BASE_PATH is changed in the future
        echo "ERROR: $REDASH_BASE_PATH not found. Make sure the scipt is in the correct directory."
    fi

    if [[ ! -e $REDASH_BASE_PATH/postgres-data ]]; then
        mkdir $REDASH_BASE_PATH/postgres-data
    else
	echo "Removing postgres settings from previous run ..."
        sudo rm -rf $REDASH_BASE_PATH/postgres-data
    fi
}

create_config() {
    if [[ -e $REDASH_BASE_PATH/env ]]; then
        rm $REDASH_BASE_PATH/env
        touch $REDASH_BASE_PATH/env
    fi

    COOKIE_SECRET=$(openssl rand -hex 16)
    SECRET_KEY=$(openssl rand -hex 16)
    POSTGRES_PASSWORD=$(openssl rand -hex 16)
    REDASH_DATABASE_URL="postgresql://postgres:${POSTGRES_PASSWORD}@redash-postgres.docker-redash-net/postgres"

    echo "PYTHONUNBUFFERED=0" >> $REDASH_BASE_PATH/env
    echo "REDASH_LOG_LEVEL=INFO" >> $REDASH_BASE_PATH/env
    echo "REDASH_REDIS_URL=redis://redash-redis.docker-redash-net:6379/0" >> $REDASH_BASE_PATH/env
    echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" >> $REDASH_BASE_PATH/env
    echo "REDASH_COOKIE_SECRET=$COOKIE_SECRET" >> $REDASH_BASE_PATH/env
    echo "REDASH_SECRET_KEY=$SECRET_KEY" >> $REDASH_BASE_PATH/env
    echo "REDASH_DATABASE_URL=$REDASH_DATABASE_URL" >> $REDASH_BASE_PATH/env
}

create_directories
create_config

