pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../external/Decimal.sol";
import "../oracle/IOracle.sol";
import "./IIncentive.sol";
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";
import "../core/CoreRef.sol";


contract UniswapIncentive is IIncentive, CoreRef {
	using Decimal for Decimal.D256;

	mapping(address => address) private _oracles;
	mapping(address => bool) private _exempt;

	bool private KILL_SWITCH = false;

	constructor(address core) 
		CoreRef(core)
	public {}

    function incentivize(
    	address sender, 
    	address receiver, 
    	address spender, 
    	uint256 amountIn
    ) public override onlyFii {
    	if (KILL_SWITCH) {
    		return;
    	}

    	if (isIncentivized(sender)) {
    		incentivizeBuy(receiver, sender, amountIn);
    	}

    	if (isIncentivized(receiver)) {
    		incentivizeSell(sender, receiver, amountIn);
    	}
    }

    function setExemptAddress(address account, bool isExempt) public onlyGovernor {
    	_exempt[account] = isExempt;
    }

    function setKillSwitch(bool enabled) public onlyGovernor {
    	KILL_SWITCH = enabled;
    }

    function setOracle(address account, address oracle) public onlyGovernor {
    	_oracles[account] = oracle;
    }

    function isExemptAddress(address account) public view returns (bool) {
    	return _exempt[account];
    }

    function isKillSwitchEnabled() public view returns (bool) {
    	return KILL_SWITCH;
    }

    function getOracle(address account) public view returns (address) {
    	return _oracles[account];
    }

    function isIncentivized(address account) public view returns (bool) {
    	return getOracle(account) != address(0x0);
    }

    // TODO partial fill calculation
    function incentivizeBuy(address target, address _pair, uint256 amountIn) internal {
    	if (isExemptAddress(target)) {
    		return;
    	}
    	Decimal.D256 memory peg = getPeg(_pair);
    	(Decimal.D256 memory price, uint reserveFii, uint reserveOther) = getUniswapPrice(_pair);

    	Decimal.D256 memory initialDeviation = getPriceDeviation(price, peg);
    	if (initialDeviation.equals(Decimal.zero())) {
    		return;
    	}

    	Decimal.D256 memory finalPrice = getFinalPrice(
    		-1 * int256(amountIn), 
    		reserveFii, 
    		reserveOther
    	);
    	Decimal.D256 memory finalDeviation = getPriceDeviation(finalPrice, peg);

    	Decimal.D256 memory completion = Decimal.one().sub(finalDeviation.div(initialDeviation));
    	uint256 incentive = calculateBuyIncentive(initialDeviation, amountIn);
    	fii().mint(target, incentive);
    }

    // TODO partial fill calculation
    function incentivizeSell(address target, address _pair, uint256 amount) internal {
    	if (isExemptAddress(target)) {
    		return;
    	}

    	Decimal.D256 memory peg = getPeg(_pair);
    	(Decimal.D256 memory price, uint reserveFii, uint reserveOther) = getUniswapPrice(_pair);

    	Decimal.D256 memory finalPrice = getFinalPrice(int256(amount), reserveFii, reserveOther);
    	Decimal.D256 memory finalDeviation = getPriceDeviation(finalPrice, peg);

    	if (finalDeviation.equals(Decimal.zero())) {
    		return;
    	}

    	Decimal.D256 memory initialDeviation = getPriceDeviation(price, peg);
    	uint256 penalty = calculateSellPenalty(finalDeviation, amount);
    	fii().burnFrom(target, penalty);
    }

    function getPeg(address _pair) internal returns (Decimal.D256 memory) {
    	IOracle oracle = IOracle(getOracle(_pair));
    	require(address(oracle) != address(0), "UniswapIncentive: no oracle for pair");
    	(Decimal.D256 memory peg, bool valid) = oracle.capture();
    	require(valid, "UniswapIncentive: oracle error");
    	return peg;
    }

    function getUniswapPrice(address _pair) internal view returns(
    	Decimal.D256 memory, 
    	uint reserveFii, 
    	uint reserveOther
    ) {
    	IUniswapV2Pair pair = IUniswapV2Pair(_pair); 
    	(uint reserve0, uint reserve1,) = IUniswapV2Pair(pair).getReserves();
    	(reserveFii, reserveOther) = pair.token0() == address(fii()) ? (reserve0, reserve1) : (reserve1, reserve0);
    	return (Decimal.ratio(reserveFii, reserveOther), reserveFii, reserveOther);
    }

    function calculateBuyIncentive(
    	Decimal.D256 memory initialDeviation, 
    	uint256 amountIn
    ) internal pure returns (uint256) {
    	return initialDeviation.mul(amountIn).asUint256();
    }

    function calculateSellPenalty(
    	Decimal.D256 memory finalDeviation, 
    	uint256 amount
    ) internal pure returns (uint256) {
    	return finalDeviation.mul(finalDeviation).mul(amount).mul(100).asUint256(); // m^2 * x * 100
    }

    function getFinalPrice(
    	int256 amount, 
    	uint256 reserveFii, 
    	uint256 reserveOther
    ) internal pure returns (Decimal.D256 memory) {
    	uint256 k = reserveFii * reserveOther;
    	uint256 adjustedReserveFii = uint256(int256(reserveFii) + amount);
    	uint256 adjustedReserveOther = k / adjustedReserveFii;
    	return Decimal.ratio(adjustedReserveFii, adjustedReserveOther); // alt: adjustedReserveFii^2 / k
    }

    function getPriceDeviation(
    	Decimal.D256 memory price, 
    	Decimal.D256 memory peg
    ) internal pure returns (Decimal.D256 memory) {
    	if (price.greaterThanOrEqualTo(peg)) {
    		return Decimal.zero();
    	}
    	Decimal.D256 memory delta = peg.sub(price, "UniswapIncentive: price exceeds peg"); // Should never error
    	return delta.div(peg);
    }
}