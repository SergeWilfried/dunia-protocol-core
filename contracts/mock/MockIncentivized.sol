pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../refs/CoreRef.sol";

contract MockIncentivized is CoreRef {

	constructor(address core) public
		CoreRef(core)
	{}

    function sendFei(
        address to,
        uint256 amount
    ) public {
        cowrie().transfer(to, amount);
    }

    function approve(address account) public {
        cowrie().approve(account, uint(-1));
    }

    function sendFeiFrom(
        address from,
        address to,
        uint256 amount
    ) public {
        cowrie().transferFrom(from, to, amount);
    }
}