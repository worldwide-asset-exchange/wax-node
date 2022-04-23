WAX Chain Integrations Notes
===========================

## WAX Cloud Wallet Account Creation

WAX provides an easy onboarding wallet for users called WAX Cloud Wallet. All of these accounts end with the suffix `.wam`.

In order to receive a wam account, one must send 5 WAX (subject to change) to the `newuser.wax` account including a memo field with the exact account name that they are assigned at sign up. The specification for the account creation transaction is as follows:

Contract: eosio.token

Action: transfer

Data Fields:
* from: exchange or user account sending the WAX on behalf of the new user
* to: newuser.wax
* quantity: 5.00000000 WAX
* memo: *.wam account name assigned to the user to generate

Example:
Assuming your exchange/sponsor account is `exchange1111`, and the user was instructed to create account `1a1a1a.wam`
```
$ cleos push action eosio.token transfer '{"from": "exchange1111", "to": "newuser.wax", "quantity": "5.00000000 WAX", "memo": "1a1a1a.wam"}' -p exchange1111
```

### Validating Memo Fields

Valid wam accounts will always end in `.wam`, and may contain any of the following characters in the prefix: ".abcdefghijklmnopqrstuvwxyz12345".

Also, the dot/period character `.` maybe replaced with the string `DOT`. This is to allow for exchanges that cannot allow the dot character in their memo field for whatever reason. This means the account name `a.b.c.wam` can also be validly expressed as `aDOTbDOTcDOTwam`

Please adjust your memo sanitizers to accomodate. Realize that you don't necessarily have to be strict about what goes in the memo since a memo can have ANY alphanumeric character in it when sending to non-`newuser.wax` accounts. The main thing is to not reject the request if the memo contains any of these prefix characters. If you cannot tolerate the `.`, the `DOT` format should be supported and likely is by default. 

IF you choose to sanitize the memo field for withdrawals to the newuser.wax account, the following regex validates a well formed memo `/^([a-z1-5.]|DOT){1,8}(\.wam|DOTwam)$/g`

### Maximums and Minimums

If a user sends less than the required 5 WAX to create their account, the newuser.wax contract will reject the transaction and it will fail when the transaction is attempted for broadcast. Be sure to build your logic to accept failed transactions and to not deduct WAX from exchange accounts on failed withdrawal attempts. Also, users should be aware that if a withdrawal fee is required by your dApp/exchange, the user must incorporate that amount over and above their account creation fee of 5 WAX. For example if the withdrawal fee is 1 WAX, the user must withdraw 6 WAX to successfully create an account

If a user sends more than the minimum needed to create their account, the excess will be depositted immediately on their newly created account. In this way, it is not possible for a user to overpay their account creation amount.

### Sponsored Account Creation/dApp Operators

For services that wish to create accounts on behalf of their users, an idempotent account creation mode is available called `refund_on_exists`. In this mode, any transferred funds will be immediately returned to the sender if the target account to create already exists. Also, if the sender sends greater than the account creation cost of 5 WAX, the change will be returned to the sender. This allows dApp operators to send a `refund_on_exists` action ahead of any user interactions to ensure account creation and not worry about whether or not the account already exists.

Realize that users who have a WAX All Access account but have not yet generated a blockchain account will still have a reserved blockchain account name that you can read in their waxjs [login](https://github.com/worldwide-asset-exchange/waxjs#2-login) information as usual, despite not having their blockchain account generated yet. This allows you to ensure that a user's account will exist so long as you send using the idempotent `refund_on_exists` mode as the first action in your transaction.

Exchange operators will generally not want to use the `refund_on_exists` mode.

The format for the `refund_on_exists` mode is the same as the regular/default newuser.wax account creation transfer with a slight modification in the memo as follows:

`<*.wam account>:refund_on_exists`

Example:

Assuming your dApp account is `dapp11111111`, and waxjs logs in account (or the user was instructed to create account) `1a1a1a.wam`
```
$ cleos push action eosio.token transfer '{"from": "dapp11111111", "to": "newuser.wax", "quantity": "5.00000000 WAX", "memo": "1a1a1a.wam:refund_on_exists"}' -p dapp11111111
```

## Accepting Deposits

Exchange operators and other services need to accept WAX deposits to perform operations on off-chain platforms. Typically an excchange will have a well known acccount on the WAX chain, like `exchange1111`. The most common deposit acceptance pattern involves associating a unique deposit memo string with every exchange user. The string should never change for any given user so that a user can reliably send to the exchange deposit account with the same memo value for all future deposits.

Exchanges should only process transactions in blocks that have already become irreversible. This can be determined by regularly querying the [latest block height](https://github.com/worldwide-asset-exchange/wax-node/blob/master/API.md#latest-block-height) RPC method, and only requesting blocks for processing that are less than or equal to the `last_irreversible_block_num` value via the [get block](https://github.com/worldwide-asset-exchange/wax-node/blob/master/API.md#get-a-block) RPC API. For improved UX, transactions received in reversible blocks maybe used to provide a quick confirmation that a user's transaction has been recognized but these transactions should never be applied to internal database balances until they are fully irreversible. Reversible transactions have a chance of becoming forked out of chain history for a number of reasons.

Exchange operators should provide visual queues to users about the deposit requirements, such as the unique memo field required to route the deposit to their account. Also, exchange operators should generally inform users to use basic deposit transactions to their deposit account that comes directly from a user's account to the exchange with no use of the eosio multisignature contract, and with no use of a smart contract that would send the deposit on a user's behalf. These kinds of transactions require extra overhead for an exchange to process that will generally not be worth the extra effort. 

