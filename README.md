Running a WAX node
===================


## Node Version

This repo currently targets the **Antelope Spring Community Edition** line, image tag `ce-v1.3.1wax01` (nodeos `v1.3.1wax01`). This is the successor to the older Antelope Leap 5.0 line (`v5.0.x`). The pinned tag lives in the `WAX_VERSION` variable at the top of `start.sh` / `start-snapshot.sh` and can be overridden without editing the scripts:

```
$ WAX_VERSION=ce-v1.3.1wax01 ./start.sh -s true -e false
```

Published image tags are listed on [Docker Hub](https://hub.docker.com/r/waxteam/waxnode/tags). To upgrade, set `WAX_VERSION` to a newer published tag, sync the new node, point your internal infrastructure at it, then decommission the old node. Spring CE 1.x is protocol-compatible with the Leap 5.0 line, so a Spring node correctly serves the current mainnet.

## Operation

Requisites:
- Docker (configured to run without sudo)
- zstd (to extract the compressed snapshot file)

Operation is controlled by two flags:
- `-s true|false` — **Start From Snapshot.** `true` downloads and loads a recent state snapshot (fast); `false` replays from genesis (very slow). Requires `zstd`/`tar` to extract the snapshot file.
- `-e true|false` — **Enable Ship Node.** `true` runs the heavier State-History (SHIP) node, which also exposes the SHIP websocket on port 8080.

Exposed ports:
- `8888` — HTTP RPC API (chain queries, transaction push)
- `8080` — SHIP websocket (**only** when started with `-e true`)
- `9876` — P2P

**Do you need SHIP (`-e true`)?** Only if you consume the State-History stream. The SHIP-based deposit listener in [wax-deposit-withdrawal](https://github.com/worldwide-asset-exchange/wax-deposit-withdrawal) needs it. A node used only to **send withdrawals** (push transactions via the RPC API) does **not** need SHIP — run it with `-e false` to avoid the extra disk and memory cost.

***NOTE*** Operate WAX node from snapshot may take several hours to download and initialization

### Run Node
1. Run a Fresh API WAX Node Instance:
```
$ ./start.sh -s false -e false
```

1. Run the API WAX Node from a Snapshot:
```
$ ./start.sh -s true -e false
```

1. Run a Fresh API WAX Node with Ship Node Enabled:
```
$ ./start.sh -s false -e true
```

1. Run the API WAX Node with Ship Node Enabled from a Snapshot:
```
$ ./start.sh -s true -e true
```
### Check Node Status
Once nodeos is running you can use curl to validate everything is working as expected.
```
$ curl http://localhost:8888/v1/chain/get_info
```

### Stop and Reset waxnode
You can manually stop the instance, like so:

```
$ ./stop.sh
```

You can also wipe out the current blockchain DB so as to start from scratch (for example in the event of a corrupted blockchain db) by running:

```
$ ./reset.sh
```

See the [API](./API.md) information to get started interacting with your WAX node.

For specific integrations notes, please see [integrations](./INTEGRATIONS.md)

### Run snapshot node

Run API node sync to designated block height X so that you can query state of block chain up to block X.

API node sync from genesis to block height X
```bash
./start-snapshot.sh -t <block height>
```

API node sync from snapshot file, depending on designated block you want to sync choose your snapshot file in [here](https://snapshots-cdn.eossweden.org/wax/5.x/)

> **Snapshot must match the node's version line.** `start.sh`/`start-snapshot.sh` pull from the `wax/5.x/` path, which is the newest snapshot line published by this provider. The Spring CE 1.x node loads `5.x`-line snapshots (Spring 1.0 is the in-place successor to Leap 5.0 and reads its snapshot format). If you pin a different `WAX_VERSION`, confirm the snapshot line is compatible with that nodeos version before using it.

```bash
./start-snapshot.sh -u <file name> -t <block height>
```

Query block chain state up to block X

```bash
$ cleos get info
$ cleos get table eosio.token WAX stat
```

It may take a long time to initialize from large snapshot file, you can check docker log to get status

```bash
$ docker logs nodeos
```

## Systemd Service

Run the wax node as a systemd service by copying this repo into /opt/wax, copying the wax.service file into /etc/systemd/system and then regestering the service. For example:

```
$ cd into/this/repo
$ sudo mkdir /opt/wax
$ sudo mkdir /var/log/wax
$ sudo cp -r . /opt/wax/
$ sudo cp ./services/apinode.service /etc/systemd/system/wax.service
$ sudo systemctl enable wax
$ sudo service wax start
```

## Configuration Details

More details on configuration the WAX nodeos instance can be found here: https://developers.eos.io/manuals/eos/v2.1/nodeos/index

Some parameters of particular interest are described below:

* `database-map-mode = heap`: can only be used if instance physical RAM is greater than or equal to chain-state-db-size-mb. For example, this means that if this parameter is set to `heap` is set then an AWS node would need to be something like r5n.2xlarge/r5n.3xlarge. If r5n.xlarge is used then this parameter needs to be skipped and swap must be configured for the AWS instance.
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


## Using AWS Notes

* Use r5n.2xlarge or r5n.3xlarge with 10K provisioned IOPS on the volume storing the blockchain data

## Working With Your WAX Node

See the [API](./API.md) information to get started interacting with your WAX node.

## Desposit and Withdrawal Application  With Your WAX Node

See the [Deposit and Withdrawal Application](https://github.com/worldwide-asset-exchange/wax-deposit-withdrawal) to track and respond to withdrawals and deposits with your WAX node.
