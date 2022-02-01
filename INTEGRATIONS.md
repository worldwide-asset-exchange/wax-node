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

NOTE 1: Valid wam accounts will always end in `.wam`, and may contain any of the following characters in the prefix: ".abcdefghijklmnopqrstuvwxyz12345", so please adjust your memo sanitizers to accomodate this.

NOTE 2: If a user sends less than the required 5 WAX to create their account, the newuser.wax contract will reject the transaction and it will fail when the transaction is attempted for braodcast. Be sure to build your logic to accept failed transactions and to not deduct WAX from exchange accounts on failed withdrawal attempts. Also, users should be aware that if a withdrawal fee is required by your dApp/exchange, the user must incoporate that amount over and above their account creation fee of 5 WAX. For example if the withdrawal fee is 1 WAX, the user must withdraw 6 WAX to successfully create an account

NOTE 3: If a user sends more than the minimum needed to create their account, the excess will be depositted immediately on their newly created account. In this way, it is not possible for a user to overpay their account creation amount.
