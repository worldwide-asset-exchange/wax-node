#!/usr/bin/env bash

WAX_VERSION=v2.0.13wax03

# Home inside docker
NODEOS_HOME=/root/.local/share/eosio/nodeos

# WAX data folder root on the host running this docker image
HOST_WAX_HOME=${HOST_WAX_HOME:-`pwd`}

MAINNET_SNAPHOT=https://snapshots-cdn.eossweden.org/wax/2.0/latest

function start_from_snapshot {
  mkdir -p $HOST_WAX_HOME/nodeos/data/
  cd $HOST_WAX_HOME/nodeos/data/
  rm *.bin
  rm latest*
  wget -O latest $MAINNET_SNAPHOT
  tar -xvzf latest
  rm latest*
  TGZ_FILES=( *.bin )
  SNAPSHOT="${TGZ_FILES[0]}"

  docker run -t --sig-proxy=true --name nodeos \
      -v $HOST_WAX_HOME/nodeos/data:$NODEOS_HOME/data \
      -v $HOST_WAX_HOME/nodeos/config:$NODEOS_HOME/config \
      -p 127.0.0.1:8888:8888 \
      -p 9876:9876 \
      waxteam/production:$WAX_VERSION \
      nodeos --verbose-http-errors --disable-replay-opts --snapshot $NODEOS_HOME/data/$SNAPSHOT
}

function start_standard {
  docker run -t --sig-proxy=true --name nodeos \
      -v $HOST_WAX_HOME/nodeos/data:$NODEOS_HOME/data \
      -v $HOST_WAX_HOME/nodeos/config:$NODEOS_HOME/config \
      -p 127.0.0.1:8888:8888 \
      -p 9876:9876 \
      waxteam/production:$WAX_VERSION \
      nodeos --genesis-json $NODEOS_HOME/config/genesis.json
}

if [ -d "$HOST_WAX_HOME/nodeos/data/state" ]; then
  start_standard
else
  start_from_snapshot
fi
