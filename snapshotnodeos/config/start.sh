NODEOS_HOME=/root/.local/share/eosio/nodeos
SYNC_TO_BLOCK_HEIGHT=$1

nodeos \
--verbose-http-errors \
--disable-replay-opts \
--terminate-at-block $SYNC_TO_BLOCK_HEIGHT \
--genesis-json $NODEOS_HOME/config/genesis.json

nodeos \
--verbose-http-errors \
--disable-replay-opts \
--genesis-json $NODEOS_HOME/config/genesis.json \
-c $NODEOS_HOME/config/config-snapshot.ini