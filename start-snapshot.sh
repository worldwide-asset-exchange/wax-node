#!/usr/bin/env bash

WAX_VERSION=v5.0.3wax02

SYNC_TO_BLOCK_HEIGHT=390757000
SNAPSHOT_URL=https://snapshots-cdn.eossweden.org/wax/5.x/
FILE_NAME=""

# Home inside docker
NODEOS_HOME=/root/.local/share/eosio/nodeos
# WAX data folder root on the host running this docker image
HOST_WAX_HOME=${HOST_WAX_HOME:-`pwd`}

function start_api_nodeos_from_snapshot {
  mkdir -p $HOST_WAX_HOME/snapshotnodeos/data/
  cd $HOST_WAX_HOME/snapshotnodeos/data/
  rm *.bin
  rm *.zst
  wget $SNAPSHOT_URL$FILE_NAME
  tar -xvzf $FILE_NAME
  rm $FILE_NAME
  TGZ_FILES=( *.bin )
  SNAPSHOT="${TGZ_FILES[0]}"

  docker run -t --sig-proxy=true --name nodeos \
      -v $HOST_WAX_HOME/snapshotnodeos/data:$NODEOS_HOME/data \
      -v $HOST_WAX_HOME/snapshotnodeos/config:$NODEOS_HOME/config \
      -p 0.0.0.0:8888:8888 \
      -p 9876:9876 \
      -d \
      waxteam/waxnode:$WAX_VERSION \
      sh -c \
      "$NODEOS_HOME/config/start-snapshot.sh $SYNC_TO_BLOCK_HEIGHT $SNAPSHOT"
}

function start_api_nodeos_stardard {
  docker run --sig-proxy=true --name nodeos \
      -v $HOST_WAX_HOME/snapshotnodeos/data:$NODEOS_HOME/data \
      -v $HOST_WAX_HOME/snapshotnodeos/config:$NODEOS_HOME/config \
      -p 0.0.0.0:8888:8888 \
      -p 9876:9876 \
      -d \
      waxteam/waxnode:$WAX_VERSION \
      sh -c \
      "$NODEOS_HOME/config/start.sh $SYNC_TO_BLOCK_HEIGHT"
}

while getopts t:u: flag
do
    case "${flag}" in
        t) SYNC_TO_BLOCK_HEIGHT=${OPTARG};;
        u) FILE_NAME=${OPTARG};;
        ?)
          echo "script usage: $(basename $0) [-s true/false] [-e true/false]" >&2
          echo "options:"
          echo "-t     Sync to block height"
          echo "-u     Snapshot url"
          exit 1
          ;;
    esac
done

if [ "$FILE_NAME" == "" ]; then
  start_api_nodeos_stardard
else
  start_api_nodeos_from_snapshot
fi
