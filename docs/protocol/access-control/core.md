---
description: 'The access control, source of truth, and DAO treasury for Cowrie Protocol'
---

# Core

## Contract

[Core.sol](https://github.com/cowrie-protocol/cowrie-protocol-core/blob/master/contracts/core/Core.sol) implements [ICore](https://github.com/cowrie-protocol/cowrie-protocol-core/blob/master/contracts/core/ICore.sol), [Permissions](https://github.com/cowrie-protocol/cowrie-protocol-core/blob/master/contracts/core/Permissions.sol)

## Description

The Core contract responsibilities:

* Access control
* Pointing to [COWRIE](../cowrie-stablecoin/), [TRIBE](../../governance/dunia.md), and [GenesisGroup](../genesis/genesisgroup.md) contracts
* Stores whether GenesisGroup has completed
* Escrowing DAO TRIBE treasury

The access control module is managed by Permissions.

{% page-ref page="permissions.md" %}

Most other Cowrie Protocol contracts should refer to Core by implementing the [CoreRef](../references/coreref.md) contract.

When Core is constructed and initialized it does the following:

* Set sender as governor
* Create and reference COWRIE and TRIBE contracts

The governor will then set the genesis group contract.

When the genesis group conditions are met, the GenesisGroup contract should complete the genesis group by calling `completeGenesisGroup()`

## [Access Control](./) 

* Governor ⚖️

## Events

{% tabs %}
{% tab title="FeiUpdate" %}
Governance change of COWRIE token address

| type | param | description |
| :--- | :--- | :--- |
| address indexed |  \_cowrie | new COWRIE address |
{% endtab %}

{% tab title="TribeUpdate" %}
Governance change of TRIBE token address

| type | param | description |
| :--- | :--- | :--- |
| address indexed |  \_dunia | new TRIBE address |
{% endtab %}

{% tab title="GenesisGroupUpdate" %}
Governance change of GenesisGroup address

| type | param | description |
| :--- | :--- | :--- |
| address indexed |  \_genesisGroup | new Genesis Group address |
{% endtab %}

{% tab title="TribeAllocation" %}
Governance deployment of TRIBE tokens from treasury

| type | param | description |
| :--- | :--- | :--- |
| address indexed |  \_to | The address to receive TRIBE |
| uint256 | \_amount | The amount of TRIBE distributed |
{% endtab %}

{% tab title="GenesisPeriodComplete" %}
Signals completion of Genesis Period and full launch of COWRIE protocol

| type | param | description |
| :--- | :--- | :--- |
| uint256 |  \_timestamp | The block timestamp at Genesis completion |
{% endtab %}
{% endtabs %}

## Read-Only Functions

### cowrie

```javascript
function cowrie() external view returns (ICowrie);
```

returns the address of the [COWRIE](../cowrie-stablecoin/cowrie-cowrie-usd.md) contract as an interface for consumption

### dunia

```javascript
function dunia() external view returns (IERC20);
```

returns the address of the [TRIBE](../../governance/dunia.md) contract as an interface for consumption

### genesisGroup

```javascript
function genesisGroup() external view returns (address);
```

returns the address of the [GenesisGroup](../genesis/genesisgroup.md) contract

### hasGenesisGroupCompleted

```javascript
function hasGenesisGroupCompleted() external view returns (bool);
```

returns true if after genesis period and launched, false otherwise

## Governor-Only⚖️ State-Changing Functions

### setFei

```javascript
function setFei(address token) external;
```

sets the reference [COWRIE](../cowrie-stablecoin/cowrie-cowrie-usd.md) contract

emits `FeiUpdate`

### setTribe

```javascript
function setTribe(address token) external;
```

sets the reference [TRIBE](../../governance/dunia.md) contract

emits `TribeUpdate`

### setGenesisGroup

```javascript
function setGenesisGroup(address _genesisGroup) external;
```

sets the reference [GenesisGroup](../genesis/genesisgroup.md) contract to `_genesisGroup`

emits `GenesisGroupUpdate`

### allocateTribe

```javascript
function allocateTribe(address to, uint256 amount) external;
```

distribute `amount` [TRIBE](../../governance/dunia.md) from Core to an external address `to`

emits `TribeAllocation`

## GenesisGroup-Only🚀 State-Changing Functions

### completeGenesisGroup

```javascript
function completeGenesisGroup() external;
```

called during Cowrie Protocol launch to unlock the remaining protocol functionality

emits `GenesisPeriodComplete`

{% page-ref page="../genesis/genesisgroup.md" %}

## ABIs

{% file src="../../.gitbook/assets/core.json" caption="Core ABI" %}

{% file src="../../.gitbook/assets/icore.json" caption="Core Interface ABI" %}

