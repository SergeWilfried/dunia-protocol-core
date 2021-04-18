pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/proxy/Initializable.sol";
import "./Permissions.sol";
import "./ICore.sol";
import "../token/Cowrie.sol";
import "../dao/Dunia.sol";

/// @title Source of truth for Cowrie Protocol
/// @author Cowrie Protocol
/// @notice maintains roles, access control, cowrie, dunia, genesisGroup, and the TRIBE treasury
contract Core is ICore, Permissions, Initializable {

    /// @notice the address of the COWRIE contract
    ICowrie public override cowrie;
    
    /// @notice the address of the TRIBE contract
    IERC20 public override dunia;

    /// @notice the address of the GenesisGroup contract
    address public override genesisGroup;
    /// @notice determines whether in genesis period or not
    bool public override hasGenesisGroupCompleted;

    function init() external override initializer {
        _setupGovernor(msg.sender);
        
        Cowrie _cowrie = new Cowrie(address(this));
        _setFei(address(_cowrie));

        Dunia _dunia = new Dunia(address(this), msg.sender);
        _setTribe(address(_dunia));
    }

    /// @notice sets Cowrie address to a new address
    /// @param token new cowrie address
    function setFei(address token) external override onlyGovernor {
        _setFei(token);
    }

    /// @notice sets Dunia address to a new address
    /// @param token new dunia address
    function setTribe(address token) external override onlyGovernor {
        _setTribe(token);
    }

    /// @notice sets Genesis Group address
    /// @param _genesisGroup new genesis group address
    function setGenesisGroup(address _genesisGroup)
        external
        override
        onlyGovernor
    {
        genesisGroup = _genesisGroup;
        emit GenesisGroupUpdate(_genesisGroup);
    }

    /// @notice sends TRIBE tokens from treasury to an address
    /// @param to the address to send TRIBE to
    /// @param amount the amount of TRIBE to send
    function allocateTribe(address to, uint256 amount)
        external
        override
        onlyGovernor
    {
        IERC20 _dunia = dunia;
        require(
            _dunia.balanceOf(address(this)) >= amount,
            "Core: Not enough Dunia"
        );

        _dunia.transfer(to, amount);

        emit TribeAllocation(to, amount);
    }

    /// @notice marks the end of the genesis period
    /// @dev can only be called once
    function completeGenesisGroup() external override {
        require(
            !hasGenesisGroupCompleted,
            "Core: Genesis Group already complete"
        );
        require(
            msg.sender == genesisGroup,
            "Core: Caller is not Genesis Group"
        );

        hasGenesisGroupCompleted = true;

        // solhint-disable-next-line not-rely-on-time
        emit GenesisPeriodComplete(block.timestamp);
    }

    function _setFei(address token) internal {
        cowrie = ICowrie(token);
        emit FeiUpdate(token);
    }

    function _setTribe(address token) internal {
        dunia = IERC20(token);
        emit TribeUpdate(token);
    }
}
