Running a WAX node
===================

Requisites:
- Docker (configured to run without sudo)

Review _nodeos/config/config.ini_ to adjust the configuration as needed. The provided config is sufficient to run a typical non-producing node with only the minimal plugins.

For a fresh WAX node instance run from snapshot first

```
$ ./start-from-snapshot.sh
```

For subsequent runs do

```
$ ./start.sh
```

Once nodeos is running you can use curl to validate everything is working as expected.
```
$ curl http://localhost:8888/v1/chain/get_info
```

## Configuration Details

More details on configuration the WAX nodeos instance can be found here: https://developers.eos.io/manuals/eos/v2.1/nodeos/index

Some parameters of particular interest are described below:

* `database-map-mode = heap`: can only be used if instance physical RAM is greater than or equal to chain-state-db-size-mb. For example, this means that if this parameter is set to `heap` is set then an AWS node would need to be something like z1d.2xlarge/z1d.3xlarge. If z1d.xlarge is used then this parameter needs to be skipped and swap must be configured for the AWS instance.
* `chain-state-db-size-mb = 131072`: the max allowed size of the chain state database. If this is too small, the db can be come corrupted when the chain state gets too large. Further, you may need to run an instance with ssufficient memeory to hold it all in memory, and utilize the `database-map-mode = heap` parameter.
* `read-mode = head`: database contains state changes by only transactions in the blockchain up to the head block; transactions received by the node are relayed if valid. This means that transactions that have not yet been included in chain are not reflected in the database state, and potentially reversible state is reflected in the blockchain database.
* `p2p-accept-transactions = false`: This prevents the node from accepting connections from peers trying to receive transaction and block info from your node. 
* `wasm-runtime = eos-vm-jit`: This is the fastest EOS VM avaialable
* `http-max-response-time-ms = 100`: Maximum time for processing an API request. Increase this if you are seeing frequent timeouts calling you node
* `abi-serializer-max-time-ms = 3000`: Maximum time for deserializing block info from peers. Increase this if your node appears to be failing due to this error.

Information on the various plugins can be found here: https://developers.eos.io/manuals/eos/latest/nodeos/plugins/index

This configuration has the following plugins already configured:

* `plugin = eosio::chain_plugin`
* `plugin = eosio::chain_api_plugin`
* `plugin = eosio::http_plugin`
* `plugin = eosio::net_plugin`
* `plugin = eosio::db_size_api_plugin`
