Running a WAX node
===================


## Upgrading Your WAX Node to Version 3.xx (Leap/Antelope Upgrade)

Wax Blockchain mainnet will be upgrading to Antelope 3.xx version on March 27, 2023 at 6 pm UTC; estimated blockheight 236,944,197

Prior to the system wide activation of the version 3.xx/Leap upgrade to the WAX core blockchain code, all operators should setup a new WAX node as per the instructions that follow. The process is exactly the same as it was prior to the 3.xx upgrade.

**Clone or checkout the latest version of this repo and run the `start.sh` script on your host as per usual (also see below), and the script will automatically fetch the latest docker image for the upgraded 3.xx chain. For reference, the latest stable wax-node docker image is [here](https://hub.docker.com/layers/waxteam/waxnode/v3.1.3wax02/images/sha256-b15b8733fc8a84eab0e157f9b7a86e716b1d4587af69a11efa29e8d952ed5d90?context=explore).**

Once the new 3.xx node is synchronized to mainnet, point your internal infrastructure to your new 3.xx WAX node. When internal services are correctly operating it is safe to decommission your previous WAX node.

Your 3.xx node will correctly run the pre-upgrade 2.xx WAX blockchain, and safely activate the new WAX blockchain features once the system wide 3.xx activation is complete.

## Operation

Requisites:
- Docker (configured to run without sudo)
- zstd (to extract the compressed snapshot file)

To operate the WAX node, you have two options, each controlled by specific parameters: -s for "Start From Snapshot" and -e for "Enable Ship Node."

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
