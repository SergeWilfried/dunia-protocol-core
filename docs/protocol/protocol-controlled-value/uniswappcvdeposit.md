---
description: A PCV deposit for holding Uniswap liquidity
---

# UniswapPCVDeposit

## Contract

[UniswapPCVDeposit.sol](https://github.com/cowrie-protocol/cowrie-protocol-core/blob/master/contracts/pcv/UniswapPCVDeposit.sol) implements [IPCVDeposit](https://github.com/cowrie-protocol/cowrie-protocol-core/blob/master/contracts/pcv/IPCVDeposit.sol), [UniRef](https://github.com/cowrie-protocol/cowrie-protocol-core/blob/master/contracts/refs/UniRef.sol)

## Description

An abstract contract for storing PCV in a Uniswap COWRIE liquidity pair

Uniswap PCV deposits receive PCV, mint the corresponding amount of COWRIE to match the Uniswap spot price, and deposit to Uniswap. They can withdraw and read in the amount of non-COWRIE PCV on Uniswap held in the contract.

When withdrawing, any excess COWRIE held is burned.

When depositing, if no existing LP exists, the oracle price is used. The oracle is a [BondingCurveOracle](https://github.com/cowrie-protocol/cowrie-protocol-core/wiki/BondingCurveOracle) subject to thawing and the bonding curve price.

## [Access Control](../access-control/) 

* Minter💰

## Events

{% tabs %}
{% tab title="Deposit" %}
Deposit to the PCV

| type | param | description |
| :--- | :--- | :--- |
| address indexed | \_from | address of the depositor |
| uint256 | \_amount | amount deposited |
{% endtab %}

{% tab title="Withdrawal" %}
Withdrawal of PCV

| type | param | description |
| :--- | :--- | :--- |
| address indexed | \_caller | the PCV controller calling this function |
| address indexed | \_to | the recipient address of the PCV |
| uint256 | \_amount | amount withdrawn |
{% endtab %}
{% endtabs %}

## Read-Only Functions

```javascript
function totalValue() external view returns (uint256);
```

Returns the effective amount of non-COWRIE PCV held by the contract. 

E.g., if the deposit holds 50% of all ETH/COWRIE liquidity on Uniswap, and there are 100,000 ETH in Uniswap, the function should return 50,000e18 wei.

## Public State-Changing Functions

### deposit

```javascript
function deposit(uint256 amount) external payable;
```

Deposits `amount` PCV into Uniswap by minting the necessary amount of COWRIE to make the liquidity provision.

E.g., if there are 50,000 ETH and 100,000,000 COWRIE on Uniswap, and the protocol receives another 500 ETH to deposit, the protocol will mint another 1,000,000 COWRIE to deposit at the current 2000 COWRIE/ETH spot price.

## PCV Controller-Only ⚙️ State-Changing Functions

### withdraw

```javascript
function withdraw(address to, uint256 amount) external;
```

Withdraws `amount` PCV from Uniswap to address `to` by withdrawing the necessary amount of liquidity and burning the corresponding COWRIE.

E.g., if the protocol owns 50,000 ETH and 100,000,000 COWRIE worth of liquidity on Uniswap, a withdrawal of 500 ETH would liquidate 1% of the LP shares and burn the extra 1,000,000 COWRIE received before transferring the 500 ETH.

## ABIs

{% file src="../../.gitbook/assets/uniswappcvdeposit.json" caption="UniswapPCVDeposit ABI" %}

{% file src="../../.gitbook/assets/ipcvdeposit.json" caption="PCVDeposit Interface ABI" %}



