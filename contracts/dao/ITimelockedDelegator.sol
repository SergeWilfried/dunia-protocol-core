pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../token/ICowrie.sol";

interface IDunia is IERC20 {
    function delegate(address delegatee) external;
}

/// @title TimelockedDelegator interface
/// @author Cowrie Protocol
interface ITimelockedDelegator {
    // ----------- Events -----------

    event Delegate(address indexed _delegatee, uint256 _amount);

    event Undelegate(address indexed _delegatee, uint256 _amount);

    // ----------- Beneficiary only state changing api -----------

    function delegate(address delegatee, uint256 amount) external;

    function undelegate(address delegatee) external returns (uint256);

    // ----------- Getters -----------

    function delegateContract(address delegatee)
        external
        view
        returns (address);

    function delegateAmount(address delegatee) external view returns (uint256);

    function totalDelegated() external view returns (uint256);

    function dunia() external view returns (IDunia);
}
