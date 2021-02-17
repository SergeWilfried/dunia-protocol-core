---
description: An ETH/USDC Uniswap TWAP snapshot oracle
---

# UniswapOracle

## Contract

[UniswapOracle.sol](https://github.com/fei-protocol/fei-protocol-core/blob/master/contracts/oracle/UniswapOracle.sol) implements [IUniswapOracle](https://github.com/fei-protocol/fei-protocol-core/blob/master/contracts/oracle/IUniswapOracle.sol), [CoreRef](https://github.com/fei-protocol/fei-protocol-core/blob/master/contracts/refs/CoreRef.sol)

## Description

The UniswapOracle contract maintains a uniswap TWAP.

Maintains a pair contract to reference and a flag for whether the target price is token0 or token1 of the pair. Has a timestamp duration which must be exceeded between oracle updates. This duration is 10 minutes at launch.

Updates should:

* take the difference between the current and prior timestamp and make sure it exceeds the duration
* get the cumulative price difference between Eth and USDC and normalize by 10\*\*12 \(the decimal difference between them\)
* divide the ratio between the cumulative price and timestamp to get a peg price, then divide by 2^112 to resolve an integer from the stored fixed point 112x112 that Uniswap uses.
* update the peg and prior cumulative and timestamp

The governor can change the duration if needed.

## Events

{% tabs %}
{% tab title="Update" %}
 new reported peg

| type | param | description |
| :--- | :--- | :--- |
| uint256 | \_peg | new peg value |
{% endtab %}

{% tab title="KillSwitchUpdate" %}
Oracle kill switch change

| type | param | description |
| :--- | :--- | :--- |
| bool | \_killSwitch | new value of the kill switch flag |
{% endtab %}

{% tab title="DurationUpdate" %}
 New TWAP duration

| type | param | description |
| :--- | :--- | :--- |
| uint256 | \_duration | new value of the TWAP duration |
{% endtab %}
{% endtabs %}

## Read-Only Functions

#### read

```javascript
function read() external view returns (Decimal.D256 memory, bool);
```

Reads the oracle value and reports the peg as FEI per underlying. The boolean returned signifies whether the reported value is valid. Invalid generally means the oracle is uninitialized or the kill switch is engaged.

#### isOutdated

```javascript
function isOutdated() external view returns (bool);
```

Returns true if the oracle is still within the `duration` window. If false, then many read functions relying on the oracle would be inaccurate.

#### killSwitch

```javascript
function killSwitch() external view returns (bool);
```

The kill switch value, if true then the read function returns invalid.

#### priorTimestamp

```javascript
function priorTimestamp() external returns (uint32);
```

Returns the prior timestamp used in the time-weighted average price calculation from the Uniswap pair.

#### priorCumulative

```javascript
function priorCumulative() external returns (uint256);
```

Returns the prior cumulative price used in the time-weighted average price calculation from the Uniswap pair.

#### duration

```javascript
function duration() external returns (uint256);
```

Returns the duration of the time-weighted average price.

#### pair

```javascript
function pair() external returns (IUniswapV2Pair);
```

Returns the referenced Uniswap pair for the oracle.

## State-Changing Functions <a id="state-changing-functions"></a>

### Public

#### update

```javascript
function update() external returns (bool);
```

Updates the oracle with new time-weighted average price data from Uniswap if the `duration` window has passed since the last update. Returns true if updated, and false otherwise.

emits `Update`

### Governor- Or Guardian-Only⚖️🛡

#### setKillSwitch

```javascript
function setKillSwitch(bool _killSwitch) external;
```

Enables or disables the oracle depending on the `_killSwitch` flag passed in.

emits `KillSwitchUpdate`

#### setDuration

```javascript
function setDuration(uint256 _duration) external;
```

Changes the time-weighted average price to `_duration` second snapshots

emits `DurationUpdate`
