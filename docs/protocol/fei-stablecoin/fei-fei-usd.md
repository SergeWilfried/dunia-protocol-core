---
description: The Cowrie USD stablecoin
---

# COWRIE \(Cowrie USD\)

## Contract

[Cowrie.sol](https://github.com/cowrie-protocol/cowrie-protocol-core/blob/master/contracts/token/Cowrie.sol) implements [ICowrie.sol](https://github.com/cowrie-protocol/cowrie-protocol-core/blob/master/contracts/token/ICowrie.sol), [CoreRef](https://github.com/cowrie-protocol/cowrie-protocol-core/blob/master/contracts/refs/CoreRef.sol), [ERC20Burnable](https://docs.openzeppelin.com/contracts/3.x/api/token/erc20#ERC20Burnable)

## Description

COWRIE is a regular ERC-20 token, based on the OpenZeppelin ERC-20Burnable code with the following modifications:

Minting and burning to any address are uncapped and accessible by any address with the Minter💰and Burner🔥 role, respectively.

At each transfer \(or transferFrom\) the following addresses are checked for a mapped incentive contract:

* COWRIE sender
* COWRIE receiver
* COWRIE operator \(msg.sender\) - commonly the same as the sender unless using transferFrom with an approved contract
* the zero address - represens an incentive to be applied on ALL transfers

If an incentive contract is found, it is called with all of the transfer parameters. Any incentive is applied after the token balances update from the transfer.

## Events

{% tabs %}
{% tab title="Minting" %}
Minting COWRIE to an address

| type | param | description |
| :--- | :--- | :--- |
| address indexed |  \_to | The recipient of the minted COWRIE |
| address indexed | \_minter | The contract that minted the COWRIE |
| uint256 | \_amount | The amount of COWRIE minted |
{% endtab %}

{% tab title="Burning" %}
Burning COWRIE from an address

| type | param | description |
| :--- | :--- | :--- |
| address indexed |  \_to | The target of the burned COWRIE |
| address indexed | \_burner | The contract that burned the COWRIE |
| uint256 | \_amount | The amount of COWRIE minted |
{% endtab %}

{% tab title="IncentiveContractUpdate" %}
setting or unsetting an incentive contract for an incentivized address

| type | param | description |
| :--- | :--- | :--- |
| address indexed |  \_incentivized | The incentivized address |
| address indexed | \_incentiveContract | The new incentive contract. address\(0\) to unset |
{% endtab %}
{% endtabs %}

## Read-Only Functions

### incentiveContract

```javascript
function incentiveContract(address account) external view returns (address);
```

returns the mapped incentive contract if `account` is an incentivized address, otherwise returns the 0 address.

{% hint style="info" %}
if the 0 address has a mapped incentive contract, then this incentive contract is called for every single COWRIE transfer.
{% endhint %}

## Burner-Only🔥 State-Changing Functions

### burnFrom

```javascript
function burnFrom(address account, uint256 amount) external;
```

Burns `amount` COWRIE from `account`. Reverts if the COWRIE balance of `account` is less than `amount`

emits `Burning`

## Minter-Only💰 State-Changing Functions

### mint

```javascript
function mint(address account, uint256 amount) external;
```

Mints `amount` COWRIE to `account`

emits `Minting`

## Governor-Only⚖️ State-Changing Functions

### setIncentiveContract

```javascript
function setIncentiveContract(address account, address incentive) external;
```

Sets the incentive contract `incentive` for `account`. If `incentive` is the 0 address this functions as an unset.

emits `IncentiveContractUpdate`

## Public State-Changing Functions

### burn

```javascript
function burn(uint256 amount) external;
```

Burns `amount` COWRIE from `msg.sender`. Reverts if the COWRIE balance of `msg.sender` is less than `amount`

emits `Burning`

### permit

```javascript
function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
) external;
```

Sets the allowance for a `spender` for `value` COWRIE from `owner` via signature. Reverts if called after `deadline`

## ABIs

{% file src="../../.gitbook/assets/cowrie.json" caption="Cowrie ABI" %}

{% file src="../../.gitbook/assets/ifei.json" caption="Cowrie Interface ABI" %}

