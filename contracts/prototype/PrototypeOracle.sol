pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../external/Decimal.sol";
import "../oracle/IOracle.sol";

contract PrototypeOracle is IOracle {
    using Decimal for Decimal.D256;

    // fixed exchange ratio
    uint256 _usdPerEth;

    constructor(uint256 usdPerEth) public {
        _usdPerEth = usdPerEth;
    }

    function setup() public override {}

    function capture() public override returns (Decimal.D256 memory, bool) {
        Decimal.D256 memory price = Decimal.from(_usdPerEth); 
        return (price, true);
    }

    function setExchangeRate(uint256 usdPerEth) public {
        _usdPerEth = usdPerEth;
    }
}