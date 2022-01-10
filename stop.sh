#!/usr/bin/env bash

if pgrep -x "nodeos" > /dev/null
then
    echo "Stopping nodeos..."

    docker exec nodeos pkill -f nodeos

    while docker ps | grep -q nodeos
    do
      docker exec nodeos pkill -f nodeos
      echo "Waiting for nodeos to shutdown..."
      sleep 1
    done
fi
docker rm nodeos
echo "Process nodeos has finished"