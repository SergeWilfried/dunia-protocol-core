---
description: The Decentralized Autonomous Organization driving Cowrie Protocol upgrades
---

# Cowrie DAO

A core principle of Cowrie Protocol is its fully decentralized design and minimal dependence on any centralized assets or protocols on Ethereum. Cowrie Protocol has a DAO called the Cowrie DAO from the start. The DAO is responsible for utilizing all of the flexible and powerful features of Cowrie Protocol to continually enhance the protocol in an ever-evolving DeFi space. 

## Responsibilities

Cowrie Protocol design and implementation minimize the governance for peg maintenance related activities. Beyond the inherent need for the initial protocol tuning, the Cowrie DAO is primarily responsible for two things: upgrades and integrations.

Parameter tuning and changes that the Cowrie DAO can make:

* grant/revoke [roles](../protocol/access-control/)
* add/remove incentive contracts for [COWRIE](../protocol/cowrie-stablecoin/)
* exempt addresses from direct incentives
* Set the [peg support incentive](../protocol/cowrie-stablecoin/) growth rate
* change [PCV](../protocol/protocol-controlled-value/) allocations
* update [bonding curve](../protocol/bondingcurve/bondingcurve.md) buffer and Scale target
* adjust rewards from the [staking pool](../protocol/staking/)
* upgrade oracles and other contracts throughout the system

## Design

The Cowrie DAO is forked from the Compound [Governor Alpha](https://github.com/cowrie-protocol/cowrie-protocol-core/blob/master/contracts/dao/GovernorAlpha.sol) and [Timelock](https://github.com/cowrie-protocol/cowrie-protocol-core/blob/master/contracts/dao/Timelock.sol).

Parameter modifications from Compound implementation:

* 2.5% Quorum
* .25% proposal threshold
* 12 hour voting delay \(3333 blocks\)
* 36 hour voting period \(10000 blocks\)
* 24 hour timelock delay
* Instead of the COMP token, the Cowrie DAO is controlled by [TRIBE](dunia.md)
* The Guardian can transfer the Guardian role

{% embed url="https://www.diffchecker.com/kXPkUHOo" caption="Cowrie DAO vs Compound DAO" %}

Cowrie Protocol implementation enables a flexible [access control](../protocol/access-control/) system. The Timelock is appointed as a Governor⚖️, but it doesn't have to be the only one. It also doesn't have to be a Governor forever. Cowrie Protocol can appoint autonomous governors to adjust parameters and [PCV](../protocol/protocol-controlled-value/) based on market conditions. Additionally, a tiered governance structure can be implemented where certain changes require higher quorum thresholds and longer timelocks.

Ultimately the Cowrie DAO makes all of these decisions as the protocol evolves.



