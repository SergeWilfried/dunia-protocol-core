---
description: The COWRIE/TRIBE Initial DEX Offering contract
---

# IDO

## Contract

[IDO.sol](https://github.com/cowrie-protocol/cowrie-protocol-core/blob/master/contracts/genesis/IDO.sol) implements [IDOInterface](https://github.com/cowrie-protocol/cowrie-protocol-core/blob/master/contracts/genesis/IDOInterface.sol), [UniRef](https://github.com/cowrie-protocol/cowrie-protocol-core/blob/master/contracts/refs/UniRef.sol), [LinearTokenTimelock](https://github.com/cowrie-protocol/cowrie-protocol-core/blob/master/contracts/utils/LinearTokenTimelock.sol)

## Description

IDO is an Initial DeFi Offering contract for listing COWRIE and TRIBE at genesis launch.

The IDO is deployed by the GenesisGroup contract. The GenesisGroup sets the initial exchange rate. The IDO should hold TRIBE tokens and mint the appropriate amount of COWRIE to match the given exchange rate. It will then send the TRIBE and COWRIE to Uniswap where it should be the only LP for the pair.

The LP shares held by the contract timelock linearly to the Cowrie Core Team and early-backers over a 4 year window from contract creation.

### Normalization

Because of slippage, when a Uniswap transaction occurs the next spot price is always higher than the price payed by the trader. 

For example, assume there are 100 COWRIE and 100 USDC in a pool. A trader sends 100 USDC to the pool to buy COWRIE and gets 50 COWRIE back. This is a 2:1 exchange rate. However now the reserves are 200 USDC and 50 COWRIE, implying a  4:1 spot exchange rate. An arbitrageur could estimate the true price is around 2:1 and back-run the trade to profit on the slippage.

The IDO pre-swap will likely have a large amount of slippage and create a massive arbitrage opportunity. For this reason we will "normalize" the price to what the Genesis Group pays \(2:1 in the above example\). The IDO simply burns from the pool back to the rate payed and then "syncs" the pool using the low level Uniswap utility.

Due to the symmetry in Uniswap trades, the burn amount is always equal to the amount of COWRIE swapped into the pool for TRIBE.

## [Access Control](../access-control/) 

* Minter💰
* Burner🔥

## Events

{% tabs %}
{% tab title="Deploy" %}
The IDO initialization with COWRIE and TRIBE. Only emitted once

| type | param | description |
| :--- | :--- | :--- |
| uint256 | \_amountFei | the amount of COWRIE deployed in the IDO |
| uint256 | \_amountTribe | the amount of TRIBE deployed in the IDO |
{% endtab %}
{% endtabs %}

## GenesisGroup-Only🚀 State-Changing Functions

### deploy

```javascript
function deploy(Decimal.D256 calldata feiRatio) external;
```

Initializes the COWRIE/TRIBE Uniswap pool with liquidity based on the amount of TRIBE held by the contract and `feiRatio` times that amount worth of COWRIE. The COWRIE for this are minted by the IDO to itself. 

### swapFei

```javascript
function swapFei(uint256 amountFei) external returns (uint256);
```

Swaps `amountFei` worth of COWRIE from the [GenesisGroup](genesisgroup.md) contract to the COWRIE/TRIBE Uniswap pool and back. The IDO must be approved for the COWRIE transfer.

Includes the "normalization" burn after the trade executes.

## Governor-Only⚖️ State-Changing Functions

### unlockLiquidity

```javascript
function unlockLiquidity() external;
```

Unlocks all of the time-locked liquidity and early vests to the beneficiary. This function is intended to be used when upgrading the primary AMM for COWRIE-TRIBE liquidity by setting the beneficiary to a pre-set upgrade co

## ABIs

{% file src="../../.gitbook/assets/ido \(1\).json" caption="IDO ABI" %}

{% file src="../../.gitbook/assets/idointerface \(1\).json" caption="IDO Interface ABI" %}

