#!/bin/sh

echo "Setup CloudProxy and Mount"

echo "> Setting up CloudProxy on $SANDBOX_ID for $PROXY_INSTANCE_NAME on unix:/tmp/database-socket"

cloud_sql_proxy --instances=$PROXY_INSTANCE_NAME=unix:/tmp/database-socket -dir=/tmp &

echo "> Started Proxy – Waiting for it to boot"
sleep 4
echo "> Proxy Setup"

echo "> Mounting staging"

cd ./backend
SANDBOX_ID=$SANDBOX_ID sh ./lib/docker/mount-cloud-proxy.sh

echo "> Mounting completed"