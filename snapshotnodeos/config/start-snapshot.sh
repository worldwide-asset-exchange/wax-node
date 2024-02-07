NODEOS_HOME=/root/.local/share/eosio/nodeos
SYNC_TO_BLOCK_HEIGHT=$1
SNAPSHOT=$2

nodeos \
--verbose-http-errors \
--disable-replay-opts \
--terminate-at-block $SYNC_TO_BLOCK_HEIGHT \
--snapshot $NODEOS_HOME/data/$SNAPSHOT

nodeos \
--verbose-http-errors \
--disable-replay-opts \
-c $NODEOS_HOME/config/config-snapshot.ini