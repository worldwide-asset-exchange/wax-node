#!/usr/bin/env bash

WAX_VERSION=v3.1.5wax01

START_FROM_SNAPSHOT=true
ENABLE_SHIP_NODE=false

# Home inside docker
NODEOS_HOME=/root/.local/share/eosio/nodeos
# WAX data folder root on the host running this docker image
HOST_WAX_HOME=${HOST_WAX_HOME:-`pwd`}

MAINNET_SNAPHOT=https://eph-snapshots.waxpub.net/wax/
FILE_NAME=latest.bin.zst

function start_api_nodeos_from_snapshot {
  mkdir -p $HOST_WAX_HOME/nodeos/data/
  cd $HOST_WAX_HOME/nodeos/data/
  rm *.bin
  rm $FILE_NAME
  wget $MAINNET_SNAPHOT$FILE_NAME
  unzstd $FILE_NAME
  rm $FILE_NAME
  TGZ_FILES=( *.bin )
  SNAPSHOT="${TGZ_FILES[0]}"

  docker run -t --sig-proxy=true --name nodeos \
      -v $HOST_WAX_HOME/nodeos/data:$NODEOS_HOME/data \
      -v $HOST_WAX_HOME/nodeos/config:$NODEOS_HOME/config \
      -p 0.0.0.0:8888:8888 \
      -p 9876:9876 \
      waxteam/waxnode:$WAX_VERSION \
      nodeos --verbose-http-errors --disable-replay-opts --snapshot $NODEOS_HOME/data/$SNAPSHOT
}

function start_api_nodeos_stardard {
  docker run -t --sig-proxy=true --name nodeos \
      -v $HOST_WAX_HOME/nodeos/data:$NODEOS_HOME/data \
      -v $HOST_WAX_HOME/nodeos/config:$NODEOS_HOME/config \
      -p 0.0.0.0:8888:8888 \
      -p 9876:9876 \
      waxteam/waxnode:$WAX_VERSION \
      nodeos --genesis-json $NODEOS_HOME/config/genesis.json
}

function start_ship_nodeos_from_snapshot {
  mkdir -p $HOST_WAX_HOME/shipnodeos/data/
  cd $HOST_WAX_HOME/shipnodeos/data/
  rm *.bin
  rm $FILE_NAME
  wget $MAINNET_SNAPHOT$FILE_NAME
  unzstd $FILE_NAME
  rm $FILE_NAME
  TGZ_FILES=( *.bin )
  SNAPSHOT="${TGZ_FILES[0]}"

  docker run -t --sig-proxy=true --name nodeos \
      -v $HOST_WAX_HOME/shipnodeos/data:$NODEOS_HOME/data \
      -v $HOST_WAX_HOME/shipnodeos/config:$NODEOS_HOME/config \
      -p 0.0.0.0:8888:8888 \
      -p 0.0.0.0:8080:8080 \
      -p 9876:9876 \
      waxteam/waxnode:$WAX_VERSION \
      nodeos --verbose-http-errors --disable-replay-opts --trace-history --chain-state-history --snapshot $NODEOS_HOME/data/$SNAPSHOT
}

function start_ship_nodeos_standard {
  docker run -t --sig-proxy=true --name nodeos \
      -v $HOST_WAX_HOME/shipnodeos/data:$NODEOS_HOME/data \
      -v $HOST_WAX_HOME/shipnodeos/config:$NODEOS_HOME/config \
      -p 0.0.0.0:8888:8888 \
      -p 0.0.0.0:8080:8080 \
      -p 9876:9876 \
      waxteam/waxnode:$WAX_VERSION \
      nodeos --disable-replay-opts --trace-history --chain-state-history --genesis-json $NODEOS_HOME/config/genesis.json
}

while getopts s:e: flag
do
    case "${flag}" in
        s) START_FROM_SNAPSHOT=${OPTARG};;
        e) ENABLE_SHIP_NODE=${OPTARG};;
        ?)
          echo "script usage: $(basename $0) [-s true/false] [-e true/false]" >&2
          echo "options:"
          echo "-s     Start From Snapshot."
          echo "-e     Enable Ship Node."
          exit 1
          ;;
    esac
done

if [ "$ENABLE_SHIP_NODE" == false ]; then
  if [ -d "$HOST_WAX_HOME/nodeos/data/state" ] || [ $START_FROM_SNAPSHOT == false ]; then
    echo "start_api_nodeos_stardard"
    start_api_nodeos_stardard
  else
    echo "start_api_nodeos_from_snapshot"
    start_api_nodeos_from_snapshot
  fi
else
  if [ -d "$HOST_WAX_HOME/shipnodeos/data/state" ] || [ $START_FROM_SNAPSHOT == false ]; then
    echo "start_ship_nodeos_standard"
    start_ship_nodeos_standard
  else
    echo "start_ship_nodeos_from_snapshot"
    start_ship_nodeos_from_snapshot
  fi
fi
