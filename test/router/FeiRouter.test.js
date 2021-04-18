const {
  minterAddress, 
  userAddress, 
  governorAddress,
  BN,
  expectRevert,
  expect,
  time,
  MAX_UINT256,
  Cowrie,
  CowrieRouter,
  MockUniswapIncentive,
  MockPair,
  MockWeth,
  getCore,
  ether
} = require('../helpers');

describe('CowrieRouter', function () {

  beforeEach(async function () {
    this.core = await getCore(true);

    this.cowrie = await Cowrie.at(await this.core.cowrie());

    this.weth = await MockWeth.new();
    this.weth.deposit({value: ether("1")});

    this.pair = await MockPair.new(this.cowrie.address, this.weth.address);
    this.pair.setReserves("50000000", "100000");

    this.incentive = await MockUniswapIncentive.new(this.core.address);
    this.core.grantMinter(this.incentive.address, {from: governorAddress});
    this.core.grantBurner(this.incentive.address, {from: governorAddress});

    await this.cowrie.setIncentiveContract(this.pair.address, this.incentive.address, {from: governorAddress});

    this.router = await CowrieRouter.new(this.pair.address, this.weth.address);
  
    this.cowrie.approve(this.router.address, "1000000000000", {from: userAddress});
    this.cowrie.mint(userAddress, "1000000000000", {from: minterAddress});
    this.cowrie.mint(this.pair.address, "50000000", {from: minterAddress});

    this.weth.mint(this.router.address, "1000000000");
    this.weth.mint(this.pair.address, "100000");

    await this.incentive.setIncentivizeRecipient(true);
  });

  describe('Buy', function () {
    describe('Mint', function() {
      describe('Not enough mint', function () {
        it('reverts', async function () {
          await expectRevert(this.router.buyFei(101, 10000, userAddress, MAX_UINT256, {value: 30, from: userAddress}), "CowrieRouter: Not enough reward");
        });
      });

      describe('Exempt with enough mint', function () {
        beforeEach(async function() {
          await this.incentive.setExempt(true);
        });

        it('reverts', async function () {
          await expectRevert(this.router.buyFei(100, 10000, userAddress, MAX_UINT256, {value: 30, from: userAddress}), "CowrieRouter: Not enough reward");
        });
      });

      describe('Sufficient mint', function () {
        it('succeeds', async function () {
          let feiBefore = await this.cowrie.balanceOf(userAddress);
          await this.router.buyFei(100, 10000, userAddress, MAX_UINT256, {value: 30, from: userAddress});
          let feiAfter = await this.cowrie.balanceOf(userAddress);
          expect(feiAfter.sub(feiBefore)).to.be.bignumber.equal(new BN('15050'));
        });
      });
    });

    describe('Deadline', function() {
      beforeEach(async function() {
        this.timestamp = await time.latest();
      });

      describe('Too late', function () {
        it('reverts', async function () {
          await expectRevert(this.router.buyFei(100, 10000, userAddress, this.timestamp.sub(new BN('10')), {value: 30, from: userAddress}), "CowrieRouter: Expired");
        });
      });

      describe('On time', function () {
        it('succeeds', async function () {
          let feiBefore = await this.cowrie.balanceOf(userAddress);
          await this.router.buyFei(100, 10000, userAddress, this.timestamp.add(new BN('10')), {value: 30, from: userAddress});
          let feiAfter = await this.cowrie.balanceOf(userAddress);
          expect(feiAfter.sub(feiBefore)).to.be.bignumber.equal(new BN('15050'));
        });
      });
    });

    describe('Slippage', function() {
      describe('Too high', function () {
        it('reverts', async function () {
          await expectRevert(this.router.buyFei(100, 10000, userAddress, MAX_UINT256, {value: 20, from: userAddress}), "CowrieRouter: Insufficient output amount");
        });
      });

      describe('Acceptable', function () {
        it('succeeds', async function () {
          let feiBefore = await this.cowrie.balanceOf(userAddress);
          await this.router.buyFei(100, 10000, userAddress, MAX_UINT256, {value: 21, from: userAddress});
          let feiAfter = await this.cowrie.balanceOf(userAddress);
          expect(feiAfter.sub(feiBefore)).to.be.bignumber.equal(new BN('10566'));
        });
      });
    });
  });

  describe('Sell', function () {
    beforeEach(async function() {
      await this.incentive.setIsMint(false);
    });

    describe('Burn', function() {
      describe('Too much burn', function () {
        it('reverts', async function () {
          await expectRevert(this.router.sellFei(99, 10000, 10, userAddress, MAX_UINT256, {from: userAddress}), "CowrieRouter: Penalty too high");
        });
      });

      describe('Sufficient burn', function () {
        it('succeeds', async function () {
          let feiBefore = await this.cowrie.balanceOf(this.pair.address);
          await this.router.sellFei(100, 10000, 10, userAddress, MAX_UINT256, {from: userAddress});
          let feiAfter = await this.cowrie.balanceOf(this.pair.address);
          expect(feiAfter.sub(feiBefore)).to.be.bignumber.equal(new BN('9900'));
        });
      });

      describe('Exempt with too much burn', function () {
        beforeEach(async function() {
          await this.incentive.setExempt(true);
        });

        it('succeeds', async function () {
          let feiBefore = await this.cowrie.balanceOf(this.pair.address);
          await this.router.sellFei(99, 10000, 10, userAddress, MAX_UINT256, {from: userAddress});
          let feiAfter = await this.cowrie.balanceOf(this.pair.address);
          expect(feiAfter.sub(feiBefore)).to.be.bignumber.equal(new BN('10000'));
        });
      });
    });

    describe('Deadline', function() {
      beforeEach(async function() {
        this.timestamp = await time.latest();
      });

      describe('Too late', function () {
        it('reverts', async function () {
          await expectRevert(this.router.sellFei(100, 10000, 10, userAddress, this.timestamp.sub(new BN('10')), {from: userAddress}), "CowrieRouter: Expired");
        });
      });

      describe('On time', function () {
        it('succeeds', async function () {
          let feiBefore = await this.cowrie.balanceOf(this.pair.address);
          await this.router.sellFei(100, 10000, 10, userAddress, this.timestamp.add(new BN('10')), {from: userAddress});
          let feiAfter = await this.cowrie.balanceOf(this.pair.address);
          expect(feiAfter.sub(feiBefore)).to.be.bignumber.equal(new BN('9900'));
        });
      });
    });

    describe('Slippage', function() {
      describe('Too high', function () {
        it('reverts', async function () {
          await expectRevert(this.router.sellFei(100, 10000, 20, userAddress, MAX_UINT256, {from: userAddress}), "CowrieRouter: Insufficient output amount");
        });
      });

      describe('Acceptable', function () {
        it('succeeds', async function () {
          let feiBefore = await this.cowrie.balanceOf(this.pair.address);
          await this.router.sellFei(100, 10000, 19, userAddress, MAX_UINT256, {from: userAddress});
          let feiAfter = await this.cowrie.balanceOf(this.pair.address);
          expect(feiAfter.sub(feiBefore)).to.be.bignumber.equal(new BN('9900'));
        });
      });
    });
  });
});