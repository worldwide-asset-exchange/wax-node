Interacting With Your WAX Node/WAX Node API options
===================================================

Requisites:
- Have a [running WAX node](./README.md#running-a-wax-node)

For specific integrations notes, please see [integrations](./INTEGRATIONS.md)

## Blockchain Explorer

The standard blockchain explorer can be found here: https://wax.bloks.io/

You can also route this explorer through your local WAX node here: https://local.bloks.io/?nodeUrl=localhost%3A8888&coreSymbol=WAX&corePrecision=8&systemDomain=eosio

## API's and Documentation

### Nodeos

Your WAX node main process is called `nodeos`. Documentation for that is found [here](https://developers.eos.io/manuals/eos/v2.1/nodeos/index)
The RPC API's are specifically [here](https://developers.eos.io/manuals/eos/v2.1/nodeos/rpc_apis/index)

### Cleos

Cleos is a convenient wrapper for the nodeos RPC API, and is bundled with your WAX node. Documentation for that is [here](https://developers.eos.io/manuals/eos/v2.1/cleos/command-reference/index)

### Eosjs

Eosjs is a JavaScript library that allows you to easily create applications interacting with the WAX blockchain using JavaScript or TypeScript. The library and documentation are found [here](https://github.com/EOSIO/eosjs)


## Examples

NOTE 1: All examples assume your WAX node is running locally and fully synced.

NOTE 2: Most examples involving cleos utilize the dockerized cleos contained in the wax-node docker image, so cleos commands are indirected through `docker exec`.

NOTE 3: For the signing example using cleos, you must [install cleos](https://developers.eos.io/manuals/eos/latest/cleos/index) on the machine that will sign and communicate with the wax-node.

### Latest block height

1. Via [nodeos RPC API](https://developers.eos.io/manuals/eos/latest/nodeos/plugins/chain_api_plugin/api-reference/index#operation/get_info) 
```
$ curl http://localhost:8888/v1/chain/get_info | jq

% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                               Dload  Upload   Total   Spent    Left  Speed
100   806  100   806    0     0    413      0  0:00:01  0:00:01 --:--:--   413
{
"server_version": "d3144fbd",
"chain_id": "1064487b3cd1a897ce03ae5b6a865651747e2e152090f99c1d19d44e01aea5a4",
"head_block_num": 163830955,
"last_irreversible_block_num": 163830738,
"last_irreversible_block_id": "09c3dbd2afd87f5e00f87d64e78c2f658edbad8b6f8c43b537f1a76b051dbf0b",
"head_block_id": "09c3dcab015e43157ca30535ac117ee513d920dbb8308fee924453c6359148a5",
"head_block_time": "2022-01-28T12:05:06.000",
"head_block_producer": "liquidstudio",
"virtual_block_cpu_limit": 1331959,
"virtual_block_net_limit": 1048576000,
"block_cpu_limit": 200000,
"block_net_limit": 1048576,
"server_version_string": "v2.0.13wax01",
"fork_db_head_block_num": 163830955,
"fork_db_head_block_id": "09c3dcab015e43157ca30535ac117ee513d920dbb8308fee924453c6359148a5",
"server_full_version_string": "v2.0.13wax01-d3144fbd3959c0bfa535fcefc23a5c18f5601d34"
}

```

2. Via [cleos](https://developers.eos.io/manuals/eos/latest/cleos/command-reference/get/info)
```
$ docker exec nodeos cleos -u http://localhost:8888 get info

{
  "server_version": "d3144fbd",
  "chain_id": "1064487b3cd1a897ce03ae5b6a865651747e2e152090f99c1d19d44e01aea5a4",
  "head_block_num": 163830997,
  "last_irreversible_block_num": 163830738,
  "last_irreversible_block_id": "09c3dbd2afd87f5e00f87d64e78c2f658edbad8b6f8c43b537f1a76b051dbf0b",
  "head_block_id": "09c3dcd5e9926312607eebb90970640e9485b7d4b340d0d541eb3cff6dc5d17f",
  "head_block_time": "2022-01-28T12:05:27.000",
  "head_block_producer": "cryptolions1",
  "virtual_block_cpu_limit": 1389101,
  "virtual_block_net_limit": 1048576000,
  "block_cpu_limit": 200000,
  "block_net_limit": 1048576,
  "server_version_string": "v2.0.13wax01",
  "fork_db_head_block_num": 163830997,
  "fork_db_head_block_id": "09c3dcd5e9926312607eebb90970640e9485b7d4b340d0d541eb3cff6dc5d17f",
  "server_full_version_string": "v2.0.13wax01-d3144fbd3959c0bfa535fcefc23a5c18f5601d34"
}
```

3. Via [eosjs](https://github.com/EOSIO/eosjs#json-rpc)
```
(async () => { 
  await rpc.get_info();
})();
```

### Get a transaction

It is recommended that you design your logic so that transactions do not have to be queried from the blokchain by hash without knowing the block they were included in. Otherwise, you will have to rely on a much bulkier node that runs the history plugin, which is deprecated and hence not recommended. To extract a transaction from a known block that it was included in, get the block as per these examples, and search for it in the `transactions` array field.

Utilities like https://wax.bloks.io allow you to manually look up transactions by hash. From there you can verify them in your node by cross referencing them by the block expressed in wax.bloks.io.

### Get a block

1. Via [nodeos RPC API](https://developers.eos.io/manuals/eos/latest/nodeos/plugins/chain_api_plugin/api-reference/index#operation/get_block) 
```
$ curl -X POST http://localhost:8888/v1/chain/get_block --data '{"block_num_or_id": 163830997}' | jq
```

2. Via [cleos](https://developers.eos.io/manuals/eos/latest/cleos/command-reference/get/block)
```
$ docker exec nodeos cleos -u http://localhost:8888 get block 163830997
```

3. Via [eosjs](https://developers.eos.io/manuals/eosjs/latest/how-to-guides/how-to-get-block-information)
```
(async () => { 
  await rpc.get_block(163830997);
})();
```

### Get address balance

1. Via [nodeos RPC API](https://developers.eos.io/manuals/eos/latest/nodeos/plugins/chain_api_plugin/api-reference/index#operation/get_currency_balance) 
```
$ curl -X POST http://localhost:8888/v1/chain/get_currency_balance --data '{"code": "eosio.token", "account": "eosriobrazil", "symbol": "WAX"}' | jq
```

2. Via [cleos](https://developers.eos.io/manuals/eos/latest/cleos/command-reference/get/currency-balance)
```
$ docker exec nodeos cleos -u http://localhost:8888 get currency balance eosio.token eosriobrazil WAX
```

2. Via [eosjs](https://developers.eos.io/manuals/eosjs/latest/how-to-guides/how-to-get-table-information)
```
(async () => {
  await rpc.get_table_rows({
    json: true,               // Get the response as json
    code: 'eosio.token',      // Contract that we target
    scope: 'eosriobrazil',    // Account that owns the data
    table: 'accounts',        // Table name
    limit: 10,                // Maximum number of rows that we want to get
    reverse: false,           // Optional: Get reversed data
    show_payer: false         // Optional: Show ram payer
  });
})();
```

### Send a signed transaction

1. Via [nodeos RPC API](https://developers.eos.io/manuals/eos/latest/nodeos/plugins/chain_api_plugin/api-reference/index#operation/get_currency_balance) 

2. Via [cleos](https://developers.eos.io/manuals/eos/latest/cleos/command-reference/get/currency-balance)

NOTE: For this example, you must [install cleos](https://developers.eos.io/manuals/eos/latest/cleos/index) on the machine that will sign and communicate with the wax-node
```
$ rm -f ~/eosio-wallet/wallet.lock ~/eosio-wallet/temp.wallet ~/eosio-wallet/keosd.sock && cleos -u http://localhost:8888 wallet create -n temp --to-console && cleos -u http://localhost:8888 wallet import -n temp

#### Enter private key for cleos to manage temporarily ####

$ cleos -u http://localhost:8888 push transaction '{
  "delay_sec": 0,
  "max_cpu_usage_ms": 0,
  "actions": [
    {
      "account": "eosio.token",
      "name": "transfer",
      "data": {
        "from": "user1",
        "to": "user2",
        "quantity": "1.00000000 WAX",
        "memo": "test send"
      },
      "authorization": [
        {
          "actor": "user1",
          "permission": "active"
        }
      ]
    }
  ]
}'
```

2. Via [eosjs](https://developers.eos.io/manuals/eosjs/latest/how-to-guides/how-to-submit-a-transaction)
```
(async () => {
  const transaction = await api.transact({
   actions: [{
     account: 'eosio',
     name: 'buyrambytes',
     authorization: [{
       actor: 'useraaaaaaaa',
       permission: 'active',
     }],
     data: {
       payer: 'useraaaaaaaa',
       receiver: 'useraaaaaaaa',
       bytes: 8192,
     },
   }]
  }, {
   blocksBehind: 3,
   expireSeconds: 30,
  });
})();
```
