#!/usr/bin/env bash

read -p "This will reset your WAX node data so you can start again from scratch. This operation requires sudo. Are you sure? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  echo "Exiting without reset"  
  [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi


HOST_WAX_HOME=${HOST_WAX_HOME:-`pwd`}

./stop.sh
sudo rm -rf $HOST_WAX_HOME/nodeos/data
sudo rm -rf $HOST_WAX_HOME/nodeos/config/protocol_features

echo "WAX node reset success"