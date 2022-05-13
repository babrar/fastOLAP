#!/bin/sh

cd $RANGER_HOME
./setup.sh
chown ranger:ranger /opt/ranger.server.keystore.jks
chmod 400 /opt/ranger.server.keystore.jks
ranger-admin start
# Keep the container running
tail -f /dev/null

