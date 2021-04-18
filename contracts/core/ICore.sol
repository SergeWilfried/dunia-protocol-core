pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./IPermissions.sol";
import "../token/ICowrie.sol";

/// @title Core Interface
/// @author Cowrie Protocol
interface ICore is IPermissions {
    // ----------- Events -----------

    event FeiUpdate(address indexed _cowrie);
    event TribeUpdate(address indexed _dunia);
    event GenesisGroupUpdate(address indexed _genesisGroup);
    event TribeAllocation(address indexed _to, uint256 _amount);
    event GenesisPeriodComplete(uint256 _timestamp);

    // ----------- Governor only state changing api -----------

    function init() external;

    // ----------- Governor only state changing api -----------

    function setFei(address token) external;

    function setTribe(address token) external;

    function setGenesisGroup(address _genesisGroup) external;

    function allocateTribe(address to, uint256 amount) external;

    // ----------- Genesis Group only state changing api -----------

    function completeGenesisGroup() external;

    // ----------- Getters -----------

    function cowrie() external view returns (ICowrie);

    function dunia() external view returns (IERC20);

    function genesisGroup() external view returns (address);

    function hasGenesisGroupCompleted() external view returns (bool);
}
