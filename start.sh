#!/usr/bin/env bash

# Home inside docker
NODEOS_HOME=/root/.local/share/eosio/nodeos

# WAX data folder root on the host running this docker image
HOST_WAX_HOME=`pwd`

docker run -t --sig-proxy=true --name wax \
    -v $HOST_WAX_HOME/nodeos/data:$NODEOS_HOME/data \
    -v $HOST_WAX_HOME/nodeos/config:$NODEOS_HOME/config \
    -p 127.0.0.1:8886:8888 \
    -p 9876:9876 \
    waxteam/production:v2.0.5wax01 \
    nodeos --genesis-json $NODEOS_HOME/config/genesis.json
