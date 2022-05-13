#!/usr/bin/env bash

if [ "$INCLUDE_COORDINATOR_NODE_PROVIDED" == true ]; then
        cp -a /opt/config/presto/coordinator/* $PRESTO_HOME/etc/
	# Trust the extracted certificate by adding it to the truststore (needed for Presto CLI)
        $JAVA_HOME/bin/keytool -keystore "$KEYSTORE_DIR"/truststore.jks \
                -alias presto_trust \
                -import -file "$KEYSTORE_DIR"/presto_cert.cer -noprompt -trustcacerts \
                -keypass testpass_rename_me \
                -storepass testpass_rename_me

fi

if [ "$INCLUDE_WORKER_NODE_PROVIDED" == true ]; then
        cp -a /opt/config/presto/worker/* $PRESTO_HOME/etc/

        MAX_RETRIES=20
        WAIT_COUNTER=0
	
        until nc -z presto-coordinator.docker-hive-net 4443
        do
            sleep 15
            if [ $WAIT_COUNTER -ge $MAX_RETRIES ]
            then
                exit 1
            fi
            WAIT_COUNTER=$((WAIT_COUNTER+1))
            echo "Retry No $WAIT_COUNTER of $MAX_RETRIES"
        done
fi

cd $PRESTO_HOME
bin/launcher start
tail -f /dev/null

