---
description: "The equal opportunity launch of Cowrie Protocol \U0001F680"
---

# Genesis

Cowrie Protocol Genesis starts at 12:01 pm PT on March 31, 2021. It will last 3 days, ending April 3, 2021. Additional details about the Genesis event are available in our Medium announcement.

## Genesis Group

The Genesis Group contract is the user entry point for Genesis participation. It provides users the ability to:

* Enter Genesis with an ETH commitment
* Optionally pre-swap TRIBE with Genesis COWRIE
* Launch Cowrie Protocol
* Redeem rewards after launch
* Emergency exit if the launch fails

{% hint style="warning" %}
Genesis entry is one-way. There is no way to redeem committed ETH, unless the launch fails.

Optional pre-swapping of TRIBE is one-way. There is no way to revert back to uncommitted Genesis ETH.
{% endhint %}

{% page-ref page="genesisgroup.md" %}

## Initial DEX Offering \(IDO\)

As part of the Genesis launch, Cowrie Protocol will supply liquidity for [COWRIE](../cowrie-stablecoin/) and [TRIBE](../../governance/dunia.md) on Uniswap. This will amount to 20% of the [TRIBE initial token distribution](https://medium.com/cowrie-protocol/the-dunia-token-distribution-887f26169e44). The corresponding COWRIE will be minted by the protocol equal to 20% of the COWRIE generated by Genesis. This sets the total TRIBE value equal to the value of COWRIE at Genesis. The liquidity for this IDO will be timelocked and owned by the Cowrie Core Team.

{% page-ref page="ido.md" %}

{% page-ref page="../references/lineartokentimelock.md" %}

## Cowrie Core Team Timelocks

The Cowrie Core Team and early-backers will own timelocked [TRIBE](../../governance/dunia.md) as well as the LP tokens associated with the IDO. These timelocks follow a linear release schedule over a 4 year window on the contract level. The Cowrie Core Team has elected a back-weighted 5 year timelock period. All tokens follow the 4 year timelock on the contract level. The difference for the team will be managed at the company level.

The TRIBE will be held in a special timelock called the TimelockedDelegator which allows for sub-delegation of portions of the held tokens, even while timelocked. If you'd like to be considered as a sponsored delegate, reach out on Discord.

{% page-ref page="timelockeddelegator.md" %}

{% page-ref page="../references/lineartokentimelock.md" %}



