#!/usr/bin/env bash
# This script sets up the dependencies required by the docker images
# of Hive, Presto and Redash, and builds the images.
set -ex

if (( $EUID != 0 )); then
    echo "ERROR: Please run script as root."
    exit
fi

# This should not need to be set, but sometimes bash doesn't pickup .zshrc variables
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
echo "INFO: JAVA_HOME is hardcoded as $JAVA_HOME. If your JAVA_HOME is different, change it accordingly in this script."

if [ "${JAVA_HOME}" == "" ]; then
    echo "ERROR: JAVA_HOME environment property not defined, aborting installation."
    exit 1
fi

SCRIPT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd)

#----------
# PRESTO
#----------

KEYSTORE_DIR="$SCRIPT_DIR"/presto/keystore
REALM=docker-hive-net
# optinally specify cloud dns -> uncomment -ext san in keytool command
CLOUD_DNS=""

if [[ ! -d $KEYSTORE_DIR ]]; then
    mkdir -p "$KEYSTORE_DIR"
else
    sudo rm -f "$KEYSTORE_DIR/*"
fi

# Generate keystore for presto
$JAVA_HOME/bin/keytool -keystore "$KEYSTORE_DIR"/keystore.jks \
        -alias presto-for-hive \
        -validity 3650 \
        -genkeypair \
        -noprompt \
        -dname "CN=*.$REALM, OU=configure_me, O=configure_me, L=configure_me, S=configure_me, C=configure_me" \
        -keyalg RSA \
        -storepass testpass_rename_me \
        -keypass testpass_rename_me \
        -keysize 4096 \
        -deststoretype pkcs12
        # -ext SAN="dns:presto-coordinator.docker-hive-net,dns:presto-worker.docker-hive-net,dns:presto-coordinator.docker-hive-net,dns:$CLOUD_DNS"

# Extract certificate from presto keystore (needed for presto-cli)
$JAVA_HOME/bin/keytool -keystore "$KEYSTORE_DIR"/keystore.jks \
        -export -alias presto-for-hive \
        -file "$KEYSTORE_DIR"/presto_cert.cer \
        -storepass testpass_rename_me

#----------
# REDASH
#----------

REDASH_CERTS_FOLDER=$SCRIPT_DIR/redash/certs
# Add presto to redash truststore

if [[ ! -d $REDASH_CERTS_FOLDER ]]; then
    mkdir -p "$REDASH_CERTS_FOLDER"
else
    sudo rm -f "$REDASH_CERTS_FOLDER/*"
fi

# Redash is a python application, so it requires a *.pem formatted certificate for its truststore. 
# However, presto stores its key as .jks, so we need to convert it.
$JAVA_HOME/bin/keytool -importkeystore \
        -srckeystore "$KEYSTORE_DIR"/keystore.jks \
        -destkeystore "$KEYSTORE_DIR"/keystore.p12 \
        -srcalias presto-for-hive \
        -srcstoretype jks \
        -deststoretype pkcs12 \
        -deststorepass testpass_rename_me \
        -srcstorepass testpass_rename_me

openssl pkcs12 -in $KEYSTORE_DIR/keystore.p12 \
        -out $KEYSTORE_DIR/presto-key.pem \
        -passin pass:testpass_rename_me \
        -passout pass:testpass_rename_me

cp "$KEYSTORE_DIR"/presto-key.pem "$REDASH_CERTS_FOLDER"

# Launch the redash setup script
chmod +x $SCRIPT_DIR/redash/setup.sh
$SCRIPT_DIR/redash/setup.sh

# Run docker-compose
sudo docker-compose -f docker-compose-data-services.yml run --rm redash-server create_db
sudo docker-compose -f docker-compose-data-services.yml up --build
