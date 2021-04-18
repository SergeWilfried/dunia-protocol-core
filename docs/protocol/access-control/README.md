---
description: Cowrie Protocol's Core access control module
---

# Access Control

Cowrie Protocol uses access control to define the system's contracts responsibilities.

System Roles:

* Governor ⚖️
* Minter 💰
* Burner 🔥
* PCV Controller ⚙️
* Guardian 🛡️

The Cowrie Core contract manages access control.

{% page-ref page="core.md" %}



### Governor ⚖️

The Governor role is the most powerful role in Cowrie Protocol. It grants and revokes all other roles in the platform. It manages a multitude of protocol parameters unique to each contract \(bonding curve targets, incentive formulas, oracle windows, and more\).

Implementing Governor as a role and not a single contract grants Cowrie Protocol flexibility to appoint automated governance contracts or different tiers of governance with varying degrees of difficulty for execution criteria.

While the role technically belongs to the Timelock, it is valuable to think of the [Cowrie DAO](../../governance/cowrie-dao.md) as the only Governor at launch, since the Cowrie DAO is the admin of the Timelock.

{% page-ref page="../../governance/cowrie-dao.md" %}

### Minter 💰 

Minters create \(mint\) [Cowrie USD](../cowrie-stablecoin/cowrie-cowrie-usd.md) and add it to any address. Minting can be a reward for the actions of supporting the peg, or an issuance mechanism for funding PCV on a bonding curve.

Minter Examples:

{% page-ref page="../protocol-controlled-value/ethuniswappcvdeposit.md" %}

{% page-ref page="../bondingcurve/ethbondingcurve.md" %}

### Burner 🔥

Burners remove \(burn\) portions of [Cowrie USD](../cowrie-stablecoin/cowrie-cowrie-usd.md) from any address. Burning occurs as a disincentive for the actions of hurting the peg.

Burner Example:

{% page-ref page="../cowrie-stablecoin/uniswapincentive.md" %}

### PCV Controller ⚙️

PCV Controllers can move [PCV](../protocol-controlled-value/) from any contract and redeploy it elsewhere. This is done to reweight the peg, facilitate integrations, or protect against adverse conditions.

PCV Controller Example:

{% page-ref page="../protocol-controlled-value/ethuniswappcvcontroller.md" %}

### Guardian 🛡️

The Guardian enables quick feature shutdowns during unforeseen events. It can revoke any role from the above described role types. It can also shut off additional protocol functionality, and force reweights. It cannot manage PCV or mint COWRIE.

{% page-ref page="../../governance/cowrie-guardian.md" %}









