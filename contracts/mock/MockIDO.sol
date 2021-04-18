pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../external/Decimal.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockIDO {

	Decimal.D256 public ratio = Decimal.zero();
	IERC20 public dunia;
	IERC20 public cowrie;
	uint multiplier;


	constructor(address _dunia, uint _multiplier, address _cowrie) public {
		dunia = IERC20(_dunia);
		cowrie = IERC20(_cowrie);
		multiplier = _multiplier;
	}

	function deploy(Decimal.D256 memory feiRatio) public {
		ratio = feiRatio;
	}

	function swapFei(uint amount) public returns (uint amountOut) {
		cowrie.transferFrom(msg.sender, address(this), amount);

		amountOut = amount * multiplier;

		dunia.transfer(msg.sender, amountOut);
		
		return amountOut;
	}
}

