const { BN, ether } = require('@openzeppelin/test-helpers');

const CoreOrchestrator = artifacts.require("CoreOrchestrator");
const GenesisGroup = artifacts.require("GenesisGroup");
const IDO = artifacts.require("IDO");
const Core = artifacts.require("Core");
const Cowrie = artifacts.require("Cowrie");
const Dunia = artifacts.require("Dunia");
const IUniswapV2Pair = artifacts.require("IUniswapV2Pair");

const UniswapOracle = artifacts.require("UniswapOracle");
const BondingCurveOracle = artifacts.require("BondingCurveOracle");

// Assumes the following:
// Genesis 20 seconds
// Scale = 100,000,000 COWRIE
// oracle update twap window is every second

module.exports = async function(callback) {
  let accounts = await web3.eth.getAccounts();
  let co = await CoreOrchestrator.deployed();
  let core = await Core.at(await co.core());
  let cowrie = await Cowrie.at(await core.cowrie());
  let dunia = await Dunia.at(await core.dunia());
  let ido = await IDO.at(await co.ido());
  let pair = await IUniswapV2Pair.at(await ido.pair());
  let uo = await UniswapOracle.at(await co.uniswapOracle());
  let bco = await BondingCurveOracle.at(await co.bondingCurveOracle());

  console.log('Init Genesis');
  await co.beginGenesis();

  await sleep(1000);
  await uo.update();
  let price = await uo.read();
  console.log(`Uniswap Oracle: price ${price[0] / 1e18}`);

  let gg = await GenesisGroup.at(await co.genesisGroup());

  let purchaseAmountA = ether(new BN('5000'));
  let purchaseAmountB = ether(new BN('5000'));
  let purchaseAmountC = ether(new BN('10000'));


  let ggPurchaseA = await gg.purchase(accounts[0], purchaseAmountA, {from: accounts[0], value: purchaseAmountA});
  // purchase from A to B
  let ggPurchaseB = await gg.purchase(accounts[1], purchaseAmountB, {from: accounts[0], value: purchaseAmountB});

  let ggPurchaseC = await gg.purchase(accounts[2], purchaseAmountC, {from: accounts[2], value: purchaseAmountC});
  
  // transfer from C to A
  await gg.transfer(accounts[0], purchaseAmountA, {from: accounts[2]});
  // approve C for A
  await gg.approve(accounts[2], purchaseAmountA, {from: accounts[0]});

  let ggCommitA = await gg.commit(accounts[0], accounts[0], purchaseAmountA, {from: accounts[0]});
  // approved commit from A to B by C
  let ggCommitC = await gg.commit(accounts[0], accounts[1], purchaseAmountA, {from: accounts[2]});

  let ggBalanceA = await gg.balanceOf(accounts[0]);
  let ggBalanceB = await gg.balanceOf(accounts[1]);
  let ggBalanceC = await gg.balanceOf(accounts[2]);
  let totalFGEN = await gg.totalSupply();

  let ggCommitedA = await gg.committedFGEN(accounts[0]);
  let ggCommitedB = await gg.committedFGEN(accounts[1]);
  let ggCommitedC = await gg.committedFGEN(accounts[2]);
  let totalCommitted = await gg.totalCommittedFGEN();

  console.log(`Total FGEN=${stringify(totalFGEN)}, FGEN A=${stringify(ggBalanceA)}, FGEN B=${stringify(ggBalanceB)}, FGEN C=${stringify(ggBalanceC)}`);
  console.log(`Total committed=${stringify(totalCommitted)}, committed FGEN A=${stringify(ggCommitedA)}, committed FGEN B=${stringify(ggCommitedB)}, committed FGEN C=${stringify(ggCommitedC)}`);

  console.log('Sleeping for 20s');
  await sleep(20000);

  let launch = await gg.launch({from: accounts[0]});
  let bcoInitPrice = await bco.initialUSDPrice();
  let ggFei = await cowrie.balanceOf(await gg.address);
  let ggTribe = await dunia.balanceOf(await gg.address);
  console.log(`GG Launch: initPrice= ${bcoInitPrice / 1e18}, cowrie=${stringify(ggFei)}, dunia=${stringify(ggTribe)}`); 

  let redeemA = await gg.redeem(accounts[0]);
  let redeemFeiA = await cowrie.balanceOf(accounts[0]);
  let redeemTribeA = await dunia.balanceOf(accounts[0]);
  console.log(`GG Redeem A: cowrie=${stringify(redeemFeiA)}, dunia=${stringify(redeemTribeA)}`);

  let redeemB = await gg.redeem(accounts[1], {from: accounts[1]});
  let redeemFeiB = await cowrie.balanceOf(accounts[1]);
  let redeemTribeB = await dunia.balanceOf(accounts[1]);
  console.log(`GG Redeem B: cowrie=${stringify(redeemFeiB)}, dunia=${stringify(redeemTribeB)}`);
  
  let redeemC = await gg.redeem(accounts[2], {from: accounts[2]});
  let redeemFeiC = await cowrie.balanceOf(accounts[2]);
  let redeemTribeC = await dunia.balanceOf(accounts[2]);
  console.log(`GG Redeem C: cowrie=${stringify(redeemFeiC)}, dunia=${stringify(redeemTribeC)}`);

  let idoReserves = await ido.getReserves();
  let feiIdoReserves = idoReserves[0];
  let tribeIdoReserves = idoReserves[1];
  let idoTotalLiquidity = await pair.totalSupply();

  console.log(`IDO Reserves: cowrie=${stringify(feiIdoReserves)}, dunia=${stringify(tribeIdoReserves)}, liquidity=${stringify(idoTotalLiquidity)}`);

  callback();
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function stringify(bn) {
  let decimals = new BN('1000000000000000000');
  return bn.div(decimals).toString();
}
