#!/usr/bin/env bash

# Home inside docker
NODEOS_HOME=/root/.local/share/eosio/nodeos

# WAX data folder root on the host running this docker image
HOST_WAX_HOME=`pwd`

MAINNET_SNAPHOT=https://snapshots-cdn.eossweden.org/wax/2.0/latest

mkdir -p $HOST_WAX_HOME/nodeos/data/
cd $HOST_WAX_HOME/nodeos/data/
rm *.bin
rm latest*
wget -O latest $MAINNET_SNAPHOT
tar -xvzf latest
rm latest*
TGZ_FILES=( *.bin )
SNAPSHOT="${TGZ_FILES[0]}"

docker run -t --sig-proxy=true --name wax \
    -v $HOST_WAX_HOME/nodeos/data:$NODEOS_HOME/data \
    -v $HOST_WAX_HOME/nodeos/config:$NODEOS_HOME/config \
    -p 127.0.0.1:8888:8888 \
    -p 9876:9876 \
    waxteam/production:v2.0.5wax01 \
    nodeos --verbose-http-errors --disable-replay-opts --snapshot $NODEOS_HOME/data/$SNAPSHOT
