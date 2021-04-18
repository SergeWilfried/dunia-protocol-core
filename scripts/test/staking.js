const { BN } = require('@openzeppelin/test-helpers');
const { MAX_UINT256 } = require("@openzeppelin/test-helpers/src/constants");

const CoreOrchestrator = artifacts.require("CoreOrchestrator");
const IDO = artifacts.require("IDO");
const Core = artifacts.require("Core");
const Dunia = artifacts.require("Dunia");
const IUniswapV2Pair = artifacts.require("IUniswapV2Pair");
const DuniaStakingRewards = artifacts.require("DuniaStakingRewards");
const DuniaRewardsDistributor = artifacts.require("DuniaRewardsDistributor");

// Assumes the following:
// Post Genesis
// Staking uninitialized
// None of the COWRIE/TRIBE LP has been redeemed and accounts[0] is the admin

// 10% of TRIBE for rewards
// 6 min reward window
// 2 min drip frequency

module.exports = async function(callback) {
  let accounts = await web3.eth.getAccounts();
  let co = await CoreOrchestrator.deployed();
  let core = await Core.at(await co.core());
  let dunia = await Dunia.at(await core.dunia());
  let ido = await IDO.at(await co.ido());
  let pair = await IUniswapV2Pair.at(await ido.pair());

  console.log('Init Staking');
  await co.initStaking();

  let distributor = await DuniaRewardsDistributor.at(await co.duniaRewardsDistributor());
  let staking = await DuniaStakingRewards.at(await co.duniaStakingRewards());

  // Reset TRIBE Dunia
  console.log('Reset TRIBE');

  await dunia.transfer(await core.address, await dunia.balanceOf(accounts[0]), {from: accounts[0]});
  await dunia.transfer(await core.address, await dunia.balanceOf(accounts[1]), {from: accounts[1]});
  await dunia.transfer(await core.address, await dunia.balanceOf(accounts[2]), {from: accounts[2]});

  // Redeem pairs
  console.log('Redeem LP');
  await ido.release(accounts[0], '1');
  let amountPair = await ido.availableForRelease();
  await ido.release(accounts[0], amountPair);
    
  console.log('Transfer LP');
  let amountPairHalf = amountPair.div(new BN('2'));
  let amountPairQuarter = amountPair.div(new BN('4'));
  await pair.transfer(accounts[1], amountPairQuarter);
  await pair.transfer(accounts[2], amountPairQuarter);

  console.log(`Pair Balances: A=${stringify(amountPairHalf)}, B=${stringify(amountPairQuarter)}, C=${stringify(amountPairQuarter)}`);
  console.log(`Approvals`);

  await pair.approve(staking.address, MAX_UINT256, {from: accounts[0]});
  await pair.approve(staking.address, MAX_UINT256, {from: accounts[1]});
  await pair.approve(staking.address, MAX_UINT256, {from: accounts[2]});

  console.log(`Waiting to drip`);
  await sleep(120000); // sleep first drip window

  // Epoch 1
  console.log('Epoch 1');

  let drip1 = await distributor.drip();
  console.log(drip1.logs);
  await staking.stake(amountPairQuarter, {from: accounts[1]});
  await staking.stake(amountPairQuarter, {from: accounts[2]});

  console.log('Sleeping 1 min');
  await sleep(60000); // sleep half drip window
  await staking.stake(amountPairHalf, {from: accounts[0]});

  console.log('Sleeping 1 min');
  await sleep(60000); // sleep half drip window

  await staking.withdraw(amountPairQuarter, {from: accounts[1]});

  console.log(`Rewards: A=${stringify(await staking.earned(accounts[0]))}, B=${stringify(await staking.earned(accounts[1]))}, C=${stringify(await staking.earned(accounts[2]))}`)
  
  // Epoch 2
  console.log('Epoch 2');
  let drip2 = await distributor.drip();
  console.log(drip2.logs);

  console.log('Sleeping 30s');
  await sleep(30000); // sleep 1/4 drip window
  await staking.withdraw(amountPairHalf, {from: accounts[0]});

  console.log('Sleeping 1 min');
  await sleep(60000); // sleep half drip window
  await staking.stake(amountPairHalf, {from: accounts[0]});

  console.log('Sleeping 30s');
  await sleep(30000); // sleep 1/4 drip window

  console.log(`Rewards: A=${stringify(await staking.earned(accounts[0]))}, B=${stringify(await staking.earned(accounts[1]))}, C=${stringify(await staking.earned(accounts[2]))}`)
  
  // Epoch 3
  console.log('Epoch 3');
  let drip3 = await distributor.drip();
  console.log(drip3.logs);
  await staking.stake(amountPairQuarter, {from: accounts[1]});

  console.log('Sleeping 1 min');
  await sleep(60000); // sleep half drip window
  await staking.exit({from: accounts[0]});

  console.log('Sleeping 1 min');
  await sleep(60000); // sleep half drip window

  await staking.exit({from: accounts[1]});
  await staking.exit({from: accounts[2]});

  let rewardsA = await dunia.balanceOf(accounts[0]);
  let rewardsB = await dunia.balanceOf(accounts[1]);
  let rewardsC = await dunia.balanceOf(accounts[2]);
  let distributorLeft = await dunia.balanceOf(distributor.address);
  let stakingLeft = await dunia.balanceOf(staking.address);

  console.log(`Reward Balances: A=${stringify(rewardsA)}, B=${stringify(rewardsB)}, C=${stringify(rewardsC)}, dist=${stringify(distributorLeft)}, stk=${stringify(stakingLeft)}`);

  callback();
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function stringify(bn) {
  let decimals = new BN('1000000000000000000');
  return bn.div(decimals).toString();
}
